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
    var note: Note?
    let settings = TagCellSettings(collectionSectionInset: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4),
                                   minimumInteritemSpacing: 10,
                                   stackMargins: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
                                   stackSpacing: 5,
                                   iconSize: 25,
                                   fontSize: 17,
                                   multiline: true,
                                   textColor: .gray,
                                   backgroundColor: UIColor(white: 0.9, alpha: 1.0),
                                   cornerRadius: 10)
    lazy var tagsProvider: TagsProvider = TagsProvider(cellSettings: settings)

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewDidLoad")

        addNoteActionBar()

        customView.titleView.returnKeyType = .done
        customView.titleView.delegate = self

        customView.tagsView.register(TagCell.self)
        customView.tagsView.dataSource = tagsProvider
        customView.tagsView.delegate = tagsProvider

        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTagsHeight()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNote()
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
        view.endEditing(true)
    }
}

// MARK: Helpers

extension NoteViewController {
    func updateTagsHeight() {
        let height = customView.tagsView.collectionViewLayout.collectionViewContentSize.height
        customView.tagsViewHeight.constant = height < 50 ? 50 : height
    }

    func updateUI() {
        guard let note = note else {
            return
        }
        customView.titleView.text = note.title
        customView.noteView.text = note.text
        // gradient
        if let layer = customView.noteView.layer as? CAGradientLayer,
            let startPointStr = note.background?.startPoint,
            let endPointStr = note.background?.endPoint,
            let cgColors = note.background?.cgColors,
            cgColors.count > 1 {
            let startPoint = NSCoder.cgPoint(for: startPointStr)
            let endPoint = NSCoder.cgPoint(for: endPointStr)
            layer.startPoint = startPoint
            layer.endPoint = endPoint
            layer.colors = cgColors
        }
        // tags
        let tags = note.tags as! Set<Tag>
        tagsProvider.tags = Array(tags)
        customView.tagsView.isHidden = tags.count == 0 ? true : false
    }

    func saveNote() {
        let title: String = customView.titleView.text ?? ""
        let text: String = customView.noteView.text ?? ""
        if title.isEmpty, text.isEmpty {
            return
        }
        guard let layer = customView.noteView.layer as? CAGradientLayer else {
            return
        }

        if note == nil {
            note = Note(context: coreDataStack.managedContext)
            let background = GradientBackgroud(context: coreDataStack.managedContext)
            note?.background = background
        }

        note?.title = title
        note?.text = text

        // background
        let startPointStr = NSCoder.string(for: layer.startPoint)
        let endPointStr = NSCoder.string(for: layer.endPoint)
        note?.background?.startPoint = startPointStr
        note?.background?.endPoint = endPointStr
        note?.background?.cgColors = layer.colors as! [CGColor]

        // tags
        let tags = note?.tags as! Set<Tag>
        let selectedTags = Set(tagsProvider.tags)
        let tagsRem = tags.subtracting(selectedTags)
        let tagsAdd = selectedTags.subtracting(tags)
        if tagsRem != tagsAdd {
            note?.removeFromTags(tagsRem as NSSet)
            note?.addToTags(tagsAdd as NSSet)
        }

        coreDataStack.saveContext()
    }
}

// MARK: UITextFieldDelegate

extension NoteViewController: UITextFieldDelegate {
    // hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: keyboard notifications

extension NoteViewController {
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        customView.scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        customView.scrollView.contentInset = UIEdgeInsets.zero
    }
}
