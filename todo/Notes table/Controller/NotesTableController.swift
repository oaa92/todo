//
//  NotesTableController.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit
import CoreData

protocol NoteEdited: class {
    func noteDidEditted(note: Note)
}

class NotesTableController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var coreDataStack: CoreDataStack!
    lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        let sort = NSSortDescriptor(key: #keyPath(Note.createdAt), ascending: false)
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 10
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex6: 0xF7ECE1)
        
        setupNavigationBar()
        setupSearchController()
        
        tableView.register(NoteCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
    }
}

// MARK: Layout

extension NotesTableController {
    func setupNavigationBar() {
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: Helpers

extension NotesTableController {
    func fetch() {
        print("FETCH")
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

// MARK: Actions

extension NotesTableController {
    @objc func addNote() {
        let note = Note(context: coreDataStack.managedContext)
        let noteController = NoteViewController()
        noteController.coreDataStack = coreDataStack
        noteController.delegate = self
        noteController.note = note
        self.navigationController?.pushViewController(noteController, animated: true)
    }
}

// MARK: UITableViewDataSource

extension NotesTableController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NoteCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let note = fetchedResultsController.object(at: indexPath)
        configurate(cell: cell, note: note)
        return cell
    }
}

// MARK: Table cell configuration

extension NotesTableController {
    func configurate(cell: NoteCell, note: Note) {
        
        //title
        if let title = note.title {
            cell.stack.insertArrangedSubview(cell.titleLabel, at: 0)
            cell.titleLabel.text = title
        }
        
        if let glayer = cell.noteView.layer as? CAGradientLayer {
            glayer.colors = [UIColor(hex6: 0xBFD6AD).cgColor, UIColor(hex6: 0xFFCAAF).cgColor]
        }
        
        cell.noteView.text = note.text
    }
}

extension NotesTableController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text == "" && fetchedResultsController.fetchRequest.predicate == nil {
            return
        }
        
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(Note.title)) CONTAINS[cd] %@", text),
            NSPredicate(format: "\(#keyPath(Note.text)) CONTAINS[cd] %@", text),
        ])
        fetchedResultsController.fetchRequest.predicate = text == "" ? nil : predicate
        fetch()
        tableView.reloadData()
    }
}

extension NotesTableController: NoteEdited {
    func noteDidEditted(note: Note) {
        tableView.reloadData()
    }
}
