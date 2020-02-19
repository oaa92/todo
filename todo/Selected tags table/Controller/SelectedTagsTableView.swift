//
//  SelectedTagsTableView.swift
//  todo
//
//  Created by Анатолий on 13/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit
import Panels

class SelectedTagsTableView: UIViewController, Panelable {
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var headerPanel: UIView!
    @IBOutlet weak var tableView: UITableView!
    private (set) var selectedTags: [Tag] = []
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.register(TagTableCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: Layout

extension SelectedTagsTableView {
    func setupView() {
        view.backgroundColor = .clear
        curveTopCorners()
        headerPanel.backgroundColor = UIColor.Palette.orange_pale.get
        tableView.backgroundColor = UIColor.Palette.grayish_orange.get
        view.layoutIfNeeded()
    }
    
    private func curveTopCorners() {
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 30, height: 0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
    
    func getUnselectAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Unselect"
        let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            print("Hi!")
            completionHandler(true)
        }
        action.backgroundColor = .lightGray
        return action
    }
    
    func getDeleteAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Delete"
        let action = UIContextualAction(style: .destructive, title: title) { _, _, completionHandler in
            print("Hi!")
            completionHandler(true)
        }
        action.backgroundColor = UIColor(hex6: 0xFB7670)
        action.image = UIImage(named: "trash")
        return action
    }
    
    func getEditAction(cellForRowAt indexPath: IndexPath) -> UIContextualAction {
        let title = "Edit"
        let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            print("Hi!")
            completionHandler(true)
        }
        action.backgroundColor = UIColor(hex6: 0x09A723)
        action.image = UIImage(named: "edit")
        return action
    }
}

extension SelectedTagsTableView {
    enum TagChangeType {
        case insert
        case delete
        case update
    }
    
    func setTags(_ tags: [Tag]) {
        selectedTags = tags
    }
    
    func addTag(_ tag: Tag) {
        selectedTags.append(tag)
        tableViewDidChangeContent(at: IndexPath(row: selectedTags.count - 1, section: 0), type: .insert)
    }
    
    func deleteTag(_ tag: Tag) {
        guard let index = selectedTags.firstIndex(of: tag) else {
            return
        }
        selectedTags.remove(at: index)
        tableViewDidChangeContent(at: IndexPath(row: index, section: 0), type: .delete)
    }
    
    func updateTag(_ tag: Tag) {
        
    }
    
    func tableViewDidChangeContent(at indexPath: IndexPath, type: TagChangeType) {
        tableView.beginUpdates()
        switch type {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath)
            configure(cell: cell!, indexPath: indexPath)
        }
        tableView.endUpdates()
    }
}

// MARK: UITableViewDataSource

extension SelectedTagsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: Table cell configuration

extension SelectedTagsTableView {
    func configure(cell: UITableViewCell, indexPath: IndexPath) {
        let tag = selectedTags[indexPath.row]
        cell.backgroundColor = .clear
        cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 10)
        cell.textLabel?.text = tag.name
        if let icon = tag.icon,
            let name = icon.name {
            cell.imageView?.image = UIImage(named: name)
            cell.imageView?.tintColor = UIColor(hex6: icon.color)
        } else {
            cell.imageView?.image = nil
        }
    }
}

// MARK: UITableViewDelegate

extension SelectedTagsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let unselectAction = getUnselectAction(cellForRowAt: indexPath)
        let editAction = getEditAction(cellForRowAt: indexPath)
        let deleteAction = getDeleteAction(cellForRowAt: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [unselectAction, editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
