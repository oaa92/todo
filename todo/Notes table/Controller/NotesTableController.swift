//
//  NotesTableController.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NotesTableController: UITableViewController {
    
    struct Note{
        let title: String
        let note: String
    }
    
    let notes = [Note(title: "t1", note: "1\n2\n3\n4\n5\n6\n7"), Note(title: "t2", note: "n2")]
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex6: 0xF7ECE1)
        
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        tableView.register(NoteCell.self)
    }
}

// MARK: Actions

extension NotesTableController {
    @objc func addNote() {
        let noteController = NoteViewController()
        self.navigationController?.pushViewController(noteController, animated: true)
    }
}

// MARK: Helpers

extension NotesTableController {

}

// MARK: UITableViewDataSource

extension NotesTableController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NoteCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let note = notes[indexPath.row]
        configurate(cell: cell, note: note)
        return cell
    }
}

// MARK: Table cell configuration

extension NotesTableController {
    func configurate(cell: NoteCell, note: Note) {
        
        //title
        if !note.title.isEmpty {
            cell.stack.insertArrangedSubview(cell.titleLabel, at: 0)
            cell.titleLabel.text = note.title
        }
        
        if let glayer = cell.noteView.layer as? CAGradientLayer {
            glayer.colors = [UIColor(hex6: 0xBFD6AD).cgColor, UIColor(hex6: 0xFFCAAF).cgColor]
        }
        
        cell.noteView.text = note.note
    }
}
