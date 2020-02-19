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
    var coreDataStack: CoreDataStack!

    let predicate = NSPredicate(format: "\(#keyPath(Note.detetedAt)) = nil")

    lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        let sort = NSSortDescriptor(key: #keyPath(Note.createdAt), ascending: false)
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
            cell.noteView.setupLayerParams()
        }

        configureTags(note: note, cell: cell)
    }

    private func configureTags(note: Note, cell: NoteCell) {
        let uid = note.uid!
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
        let tags = note.tags as! Set<Tag>
        guard tags.count > 0 else {
            return nil
        }
        let provider = TagsCloudDataSource(cellSettings: settings)
        let collectionViewWidth = UIScreen.main.bounds.width -
            (cell.stack.layoutMargins.left + cell.stack.layoutMargins.right) -
            (settings.collectionSectionInset.left + settings.collectionSectionInset.right) - 50
        var sumWidth: CGFloat = 0
        var addTagsCount = 0
        for tag in tags {
            let size = provider.getSizeForTag(tag: tag,
                                              sectionInset: settings.collectionSectionInset,
                                              collectionViewWidth: collectionViewWidth)
            sumWidth += size.width + settings.minimumInteritemSpacing
            if sumWidth >= collectionViewWidth {
                if addTagsCount > 0 {
                    let otherTags = Tag(entity: Tag.entity(), insertInto: nil)
                    otherTags.name = "+\(tags.count - addTagsCount)"
                    provider.tags.append(otherTags)
                } else {
                    provider.tags.append(tag)
                }
                break
            } else {
                provider.tags.append(tag)
                addTagsCount += 1
            }
        }
        return provider
    }
}
