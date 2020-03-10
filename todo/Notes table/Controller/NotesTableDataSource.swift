//
//  NotesTableDataSource.swift
//  todo
//
//  Created by Анатолий on 17/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import CoreData
import UIKit

class NotesTableDataSource: NSObject {
    var locale: Locale!
    var coreDataStack: CoreDataStack!
    var predicate: NSPredicate!

    lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        let sort = NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = self.predicate
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 10
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.managedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }()

    private let settings = TagsCloudSettings(collectionSectionInset: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4),
                                             minimumInteritemSpacing: 10,
                                             stackMargins: UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5),
                                             stackSpacing: 3,
                                             iconSize: 10,
                                             fontSize: 12,
                                             textColor: .gray,
                                             backgroundColor: UIColor(white: 0.9, alpha: 1.0),
                                             cornerRadius: 5)

    var providers: [UUID: TagsCloudDataSource] = [:]
}

extension NotesTableDataSource {
    func removeProvidersForNotVisibleNotes() {
        let uids: Set<UUID> = Set(fetchedResultsController.fetchedObjects?.compactMap { $0.uid } ?? [])
        for key in providers.keys {
            if !uids.contains(key) {
                providers.removeValue(forKey: key)
            }
        }
    }
}

// MARK: UITableViewDataSource

extension NotesTableDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NoteCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Table cell configuration

extension NotesTableDataSource {
    func configure(cell: NoteCell, indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)

        // title
        if let title = note.title {
            cell.titleLabel.text = title
            cell.titleLabel.isHidden = false
        } else {
            cell.titleLabel.text = ""
            cell.titleLabel.isHidden = true
        }

        // text
        cell.noteView.text = note.text
        if let layer = cell.noteView.layer as? CAGradientLayer,
            let background = note.background,
            let startPointStr = background.startPoint,
            let endPointStr = background.endPoint,
            background.cgColors.count > 1 {
            let startPoint = NSCoder.cgPoint(for: startPointStr)
            let endPoint = NSCoder.cgPoint(for: endPointStr)
            layer.startPoint = startPoint
            layer.endPoint = endPoint
            layer.colors = background.cgColors
        } else {
            cell.noteView.setupDefaultLayerParams()
        }

        configureTags(note: note, cell: cell)
    }

    private func configureTags(note: Note, cell: NoteCell) {
        guard let uid = note.uid else {
            return
        }
        if providers[uid] == nil {
            providers[uid] = createProvider(note: note, cell: cell)
        }
        let tagsProvider = providers[uid]
        cell.tagsView.register(TagsCloudCell.self)
        cell.tagsView.dataSource = tagsProvider
        cell.tagsView.delegate = tagsProvider
        cell.tagsView.reloadData()
        cell.tagsView.isHidden = tagsProvider == nil ? true : false
    }

    private func createProvider(note: Note, cell: NoteCell) -> TagsCloudDataSource? {
        var tags = Array((note.tags as? Set<Tag>) ?? [])
        guard tags.count > 0 else {
            return nil
        }
        tags.sort(by: { $0.name ?? "" < $1.name ?? "" })
        let provider = TagsCloudDataSource(cellSettings: settings)
        let collectionViewWidth = UIScreen.main.bounds.width -
            (cell.stack.layoutMargins.left + cell.stack.layoutMargins.right) -
            (settings.collectionSectionInset.left + settings.collectionSectionInset.right) - 50
        
        let manager = NoteTagsManager()
        manager.locale = locale
        let notifications = (note.notifications ?? []) as! Set<NoteNotification>
        let tagsWithNotifications = manager.addNotificationTag(tags: tags, notifications: notifications)
        manager.tagsForMaxWidth(tags: tagsWithNotifications, provider: provider, maxWidth: collectionViewWidth)
        return provider
    }
}
