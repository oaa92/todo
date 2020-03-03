//
//  NoteViewController.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Floaty

class NoteViewController: CustomViewController<NoteView> {
    var coreDataStack: CoreDataStack!
    var note: Note?
    let settings = TagsCloudSettings(collectionSectionInset: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4),
                                     minimumInteritemSpacing: 10,
                                     stackMargins: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
                                     stackSpacing: 5,
                                     iconSize: 25,
                                     fontSize: 17,
                                     multiline: true,
                                     textColor: .gray,
                                     backgroundColor: UIColor(white: 0.9, alpha: 1.0),
                                     cornerRadius: 10)
    lazy var tagsProvider: TagsCloudDataSource = TagsCloudDataSource(cellSettings: settings)
    var notifications: Set<NoteNotification> = []

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewDidLoad")
        
        notifications = (note?.notifications ?? []) as! Set<NoteNotification>

        addActionBar()
        setFloatyItems()

        customView.titleView.delegate = self

        customView.tagsView.register(TagsCloudCell.self)
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
    private func addActionBar() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let bar = UIToolbar()
        bar.items = [space, doneItem]
        bar.sizeToFit()
        customView.noteView.inputAccessoryView = bar
    }
    
    private func setFloatyItems() {
        addFloatyItem(icon: UIImage(named: "tag"), handler: {
            _ in
            let tagsSet: Set<Tag> = (self.note?.tags ?? []) as! Set<Tag>
            let tags: [Tag] = Array(tagsSet)
            let tagsTableController = TagsTableController()
            tagsTableController.coreDataStack = self.coreDataStack
            tagsTableController.panel.setTags(tags)
            tagsTableController.tagsSelectionDelegate = self
            self.navigationController?.pushViewController(tagsTableController, animated: true)
        })
        addFloatyItem(icon: UIImage(named: "notification")) {
            _ in
            let notificationController = NotificationController()
            notificationController.coreDataStack = self.coreDataStack
            notificationController.notifications = self.notifications
            notificationController.noteNotificationsDelegate = self
            self.navigationController?.pushViewController(notificationController, animated: true)
        }
    }

    private func addFloatyItem(title: String? = nil, icon: UIImage? = nil, handler: ((FloatyItem) -> Void)? = nil) {
        let item = FloatyItem()
        item.title = title
        item.icon = icon
        item.handler = handler
        customView.floaty.addItem(item: item)
    }
}

// MARK: Helpers

extension NoteViewController {
    private func updateTagsHeight() {
        let height = customView.tagsView.collectionViewLayout.collectionViewContentSize.height
        customView.tagsViewHeight.constant = height < 50 ? 50 : height
    }

    private func updateUI() {
        guard let note = note else {
            return
        }

        // title
        customView.titleView.text = note.title
        
        // text
        customView.noteView.text = note.text
        
        //background
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
        } else {
            customView.noteView.setupLayerParams()
        }
        
        // tags
        let tags = note.tags as! Set<Tag>
        tagsProvider.tags = Array(tags)
        customView.tagsView.reloadData()
        customView.tagsView.isHidden = tags.count == 0 ? true : false
    }
}

// MARK: Actions

extension NoteViewController {
    @objc func doneTapped() {
        view.endEditing(true)
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
        customView.floaty.isHidden = true
    }

    @objc func keyboardWillHide(notification: Notification) {
        customView.scrollView.contentInset = UIEdgeInsets.zero
        customView.floaty.isHidden = false
    }
}

// MARK: TagsSelectionProtocol

extension NoteViewController: TagsSelectionProtocol {
    func tagsDidSelect(tags: [Tag]) {
        tagsProvider.tags = tags
        customView.tagsView.reloadData()
    }
}

// MARK: NoteNotificationsProtocol

extension NoteViewController: NoteNotificationsProtocol {
    func notificationsDidSet(notifications: Set<NoteNotification>) {
        self.notifications = notifications
    }
}

// MARK: Core Data

extension NoteViewController {
    private func saveNote() {
        guard let layer = customView.noteView.layer as? CAGradientLayer else {
            return
        }
        let title: String = customView.titleView.text ?? ""
        let text: String = customView.noteView.text ?? ""
        
        let note: Note
        if let cnote = self.note {
            note = cnote
        } else {
            note = Note(context: coreDataStack.managedContext)
            self.note = note
        }
        
        note.title = title
        note.text = text
        
        saveBackground(note: note, layer: layer)
        
        // tags
        let tags = note.tags as! Set<Tag>
        let selectedTags = Set(tagsProvider.tags)
        let tagsRem = tags.subtracting(selectedTags)
        let tagsAdd = selectedTags.subtracting(tags)
        if tagsRem != tagsAdd {
            note.removeFromTags(tagsRem as NSSet)
            note.addToTags(tagsAdd as NSSet)
        }
        
        //notifications
        saveNotifications(note: note)
        
        coreDataStack.saveContext()
    }
    
    private func saveBackground(note: Note, layer: CAGradientLayer) {
        let selectedBackground = getBackground(layer: layer)
        if let background = note.background,
            selectedBackground.compare(with: background) {
            return
        }
        // search background in core data
        do {
            let fetchRequest = selectedBackground.fetchEquals
            let backgrounds = try coreDataStack.managedContext.fetch(fetchRequest)
            if backgrounds.count > 0 {
                deleteOldBackgroundIfNeeded(background: note.background)
                note.background = backgrounds[0]
                return
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return
        }
        // insert background to core data
        coreDataStack.managedContext.insert(selectedBackground)
        deleteOldBackgroundIfNeeded(background: note.background)
        note.background = selectedBackground
    }
    
    private func getBackground(layer: CAGradientLayer) -> GradientBackgroud {
        let background = GradientBackgroud(entity: GradientBackgroud.entity(), insertInto: nil)
        let startPointStr = NSCoder.string(for: layer.startPoint)
        let endPointStr = NSCoder.string(for: layer.endPoint)
        background.startPoint = startPointStr
        background.endPoint = endPointStr
        background.cgColors = layer.colors as! [CGColor]
        return background
    }
    
    private func deleteOldBackgroundIfNeeded(background: GradientBackgroud?) {
        guard let background = background else {
            return
        }
        if background.notes?.count == 1 {
            coreDataStack.managedContext.delete(background)
        }
    }
    
    private func saveNotifications(note: Note) {
        let currentNotifications = note.notifications as! Set<NoteNotification>
        let savedNotifications = notifications

        var notificationsRem: Set<NoteNotification> = []
        var notificationsAdd: Set<NoteNotification> = []

        let calendarCurrentNotifications = currentNotifications.compactMap { $0 as? CalendarNotification }
        let calendarSavedNotifications = savedNotifications.compactMap { $0 as? CalendarNotification }
        
        //subtracting calendarSavedNotifications from calendarCurrentNotifications
        let remArr = calendarNotificationsSubtracting(a: calendarCurrentNotifications, b: calendarSavedNotifications)
        remArr.forEach { notificationsRem.insert($0) }
        
        //subtracting calendarCurrentNotifications from calendarSavedNotifications
        let addArr = calendarNotificationsSubtracting(a: calendarSavedNotifications, b: calendarCurrentNotifications)
        addArr.forEach{ notificationsAdd.insert($0) }

        guard notificationsRem.count > 0 || notificationsAdd.count > 0 else {
            return
        }
        notificationsAdd.forEach {self.coreDataStack.managedContext.insert($0)}
        note.removeFromNotifications(notificationsRem as NSSet)
        note.addToNotifications(notificationsAdd as NSSet)
    }
    
    private func calendarNotificationsSubtracting(a: [CalendarNotification],
                                                  b: [CalendarNotification]) -> [CalendarNotification] {
        var result: [CalendarNotification] = []
        for notification in a {
            let isContains = b.contains { $0.compare(with: notification) }
            if !isContains {
                result.append(notification)
            }
        }
        return result
    }
}
