//
//  TagsTableController.swift
//  todo
//
//  Created by Анатолий on 12/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import Panels

class TagsTableController: CustomViewController<TagsTableView>, OverlayViewProtocol {
    var coreDataStack: CoreDataStack!
    lazy var panel: SelectedTagsTableViewController = {
        let panel = UIStoryboard.instantiatePanel(identifier: "SelectedTagsPanel") as! SelectedTagsTableViewController
        panel.coreDataStack = self.coreDataStack
        panel.tagUnselectionDelegate = self
        return panel
    }()

    var overlayView = UIView()

    weak var tagsSelectionDelegate: TagsSelectionProtocol?

    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                     target: self,
                                                     action: #selector(addTag))
    private lazy var customEditButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editButtonPressed))
    private lazy var deleteButtonItem = UIBarButtonItem(image: UIImage(named: "trash"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(deleteButtonPressed))
    private lazy var cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                        target: self,
                                                        action: #selector(cancelButtonPressed))
    private let searchController = UISearchController(searchResultsController: nil)

    private lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        let sort = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.managedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }()

    private var panelIsShowing: Bool = false
    private lazy var panelManager: Panels = {
        let manager = Panels(target: self)
        manager.delegate = self
        return manager
    }()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupOverlayView()
        setupNavigationBar()
        setupSearchController()

        customView.tableView.register(TagTableCell.self)
        customView.tableView.dataSource = self
        customView.tableView.delegate = self

        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController.delegate = self
        if !panelIsShowing {
            showPanel()
            panelIsShowing = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = tagsSelectionDelegate {
            delegate.tagsDidSelect(tags: panel.selectedTags)
        }
    }
}

// MARK: Layout

extension TagsTableController {
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("Tags", comment: "")
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.setLeftBarButton(customEditButtonItem, animated: false)
        navigationItem.setRightBarButton(addButtonItem, animated: false)
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: Helpers

extension TagsTableController {
    private func fetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    private func showPanel() {
        var panelConfiguration = PanelConfiguration(size: .thirdQuarter, margin: 0, visibleArea: 50)
        panelConfiguration.keyboardObserver = false
        panelManager.show(panel: panel, config: panelConfiguration)
    }

    private func exitFromEditMode() {
        customView.tableView.setEditing(false, animated: true)
        navigationItem.setLeftBarButton(customEditButtonItem, animated: true)
        navigationItem.setRightBarButton(addButtonItem, animated: true)
    }
}

// MARK: Actions

extension TagsTableController {
    @objc private func addTag() {
        let tagController = TagViewController()
        tagController.coreDataStack = coreDataStack
        navigationController?.pushViewController(tagController, animated: true)
    }

    @objc private func editButtonPressed() {
        customView.tableView.setEditing(true, animated: true)
        deleteButtonItem.isEnabled = false
        navigationItem.setLeftBarButton(deleteButtonItem, animated: true)
        navigationItem.setRightBarButton(cancelButtonItem, animated: true)
    }

    @objc private func cancelButtonPressed() {
        exitFromEditMode()
    }

    @objc private func deleteButtonPressed() {
        if let paths = customView.tableView.indexPathsForSelectedRows {
            let tags = paths.map { fetchedResultsController.object(at: $0) }
            tags.forEach { $0.delete(coreDataStack: coreDataStack) }
            coreDataStack.saveContext()
        }
        exitFromEditMode()
    }
}

// MARK: UITableViewDataSource

extension TagsTableController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Table cell configuration

extension TagsTableController {
    private func configure(cell: TagTableCell, indexPath: IndexPath) {
        let tag = fetchedResultsController.object(at: indexPath)
        let icon: Icon? = tag.icon
        cell.configure(text: tag.name, imageName: icon?.name, color: icon?.color)
        setSelection(cell: cell, tag: tag)
    }

    private func setSelection(cell: TagTableCell, tag: Tag) {
        if panel.selectedTags.contains(tag) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}

// MARK: UITableViewDelegate

extension TagsTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tag = fetchedResultsController.object(at: indexPath)
        let actionManager = TagActionCreator()
        actionManager.coreDataStack = coreDataStack
        let editAction = actionManager.getEditAction(tag: tag, navigationController: navigationController)
        let deleteAction = actionManager.getDeleteAction(tag: tag)
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            deleteButtonItem.isEnabled = true
            return
        }
        let tag = fetchedResultsController.object(at: indexPath)
        if panel.selectedTags.contains(tag) {
            panel.deleteTag(tag)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            panel.addTag(tag)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        exitFromEditMode()
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

// MARK: UISearchResultsUpdating

extension TagsTableController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text == "", fetchedResultsController.fetchRequest.predicate == nil {
            return
        }

        let predicate = NSPredicate(format: "\(#keyPath(Tag.name)) CONTAINS[cd] %@", text)
        fetchedResultsController.fetchRequest.predicate = text == "" ? nil : predicate
        fetch()
        customView.tableView.reloadData()
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension TagsTableController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                break
            }
            customView.tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let tag = anObject as? Tag,
                let indexPath = indexPath else {
                break
            }
            if panel.selectedTags.contains(tag) {
                panel.deleteTag(tag)
            }
            customView.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let tag = anObject as? Tag,
                let indexPath = indexPath else {
                break
            }
            if panel.selectedTags.contains(tag) {
                panel.updateTag(tag)
            }
            if let cell = customView.tableView.cellForRow(at: indexPath) as? TagTableCell {
                configure(cell: cell, indexPath: indexPath)
            }
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else {
                break
            }
            customView.tableView.deleteRows(at: [indexPath], with: .automatic)
            customView.tableView.insertRows(at: [newIndexPath], with: .automatic)
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.endUpdates()
    }
}

// MARK: TagUnselectionProtocol

extension TagsTableController: TagUnselectionProtocol {
    func tagDidUnselect(tag: Tag) {
        guard let indexPath = fetchedResultsController.indexPath(forObject: tag),
            let cell = customView.tableView.cellForRow(at: indexPath) as? TagTableCell else {
            return
        }
        configure(cell: cell, indexPath: indexPath)
    }
}

// MARK: PanelNotifications

extension TagsTableController: PanelNotifications {
    func panelDidPresented() {}

    func panelDidOpen() {
        showOverlayView(parent: customView)
    }

    func panelDidCollapse() {
        hideOverlayView()
    }
}
