//
//  NoteViewController.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NoteViewController: CustomViewController<NoteView> {
    var coreDataStack: CoreDataStack!
    weak var delegate: NoteEdited?
    var note: Note = Note()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        customView.titleView.returnKeyType = .done
        addNoteActionBar()
        
        customView.titleView.delegate = self
        
        if let glayer = customView.noteView.layer as? CAGradientLayer {
            glayer.colors = [UIColor(hex6: 0xBFD6AD).cgColor, UIColor(hex6: 0xFFCAAF).cgColor]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let delegate = delegate {
            note.title = customView.titleView.text
            note.text = customView.noteView.text
            
            coreDataStack.saveContext()
            delegate.noteDidEditted(note: note)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Layout

extension NoteViewController {
    func addNoteActionBar() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let bar = UIToolbar()
        bar.items = [space, doneItem]
        bar.sizeToFit()
        customView.noteView.inputAccessoryView = bar
    }
}

// MARK: Actions

extension NoteViewController {
    @objc func doneTapped() {
        self.view.endEditing(true)
    }
}

// MARK: Helpers

extension NoteViewController {
    
}

// MARK: UITextFieldDelegate

extension NoteViewController: UITextFieldDelegate {
    //hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: keyboard notifications

extension NoteViewController {
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        customView.scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        customView.scrollView.contentInset = UIEdgeInsets.zero
    }
}
