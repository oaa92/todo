//
//  NoteViewController.swift
//  todo
//
//  Created by Анатолий on 29/01/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Floaty

class NoteViewController: CustomViewController<NoteView> {
    var locale: Locale!
    var coreDataStack: CoreDataStack!
    var notificationsManager: NotificationsManager!
    var note: Note?
    weak var noteDelegate: NoteProtocol?

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
    private lazy var tagsProvider: TagsCloudDataSource = TagsCloudDataSource(cellSettings: settings)

    private var notifications: Set<NoteNotification> = []

    private let infoSettings = TagsCloudSettings(collectionSectionInset: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 60),
                                                 minimumInteritemSpacing: 10,
                                                 stackMargins: UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5),
                                                 stackSpacing: 3,
                                                 iconSize: 10,
                                                 fontSize: 12,
                                                 textColor: .gray,
                                                 backgroundColor: UIColor(white: 0.9, alpha: 1.0),
                                                 cornerRadius: 5)

    private lazy var infoProvider: TagsCloudDataSource = TagsCloudDataSource(cellSettings: infoSettings)

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        notifications = (note?.notifications ?? []) as! Set<NoteNotification>

        addActionBar()
        setFloatyItems()

        customView.titleView.delegate = self

        customView.tagsView.register(TagsCloudCell.self)
        customView.tagsView.dataSource = tagsProvider
        customView.tagsView.delegate = tagsProvider

        customView.infoView.register(TagsCloudCell.self)
        customView.infoView.dataSource = infoProvider
        customView.infoView.delegate = infoProvider

        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTagsHeight(view: customView.tagsView, minHeight: 50)
        updateTagsHeight(view: customView.infoView, minHeight: 25)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateNoteInfo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNote()
        
        if let note = note,
            let delegate = noteDelegate {
            delegate.updateNote(note: note)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Layout

extension NoteViewController {
    private func addActionBar() {
        let palette = UIBarButtonItem(image: UIImage(named: "palette"), style: .plain, target: self, action: #selector(paletteTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneTitle = NSLocalizedString("Done", comment: "")
        let doneItem = UIBarButtonItem(title: doneTitle, style: .plain, target: self, action: #selector(doneTapped))
        let frame: CGRect

        if #available(iOS 13, *) {
            frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        } else {
            frame = .zero
        }
        let bar = UIToolbar(frame: frame)
        bar.backgroundColor = UIColor.Palette.grayish_orange.get
        bar.items = [palette, space, doneItem]
        bar.sizeToFit()
        customView.noteView.inputAccessoryView = bar
    }
}

// MARK: Floaty

extension NoteViewController {
    private func setFloatyItems() {
        addFloatyItem(icon: UIImage(named: "tag"), handler: {
            _ in
            let tags = NoteTagsManager().tagsWithoutTemp(tags: self.tagsProvider.tags)
            let tagsTableController = TagsTableController()
            tagsTableController.coreDataStack = self.coreDataStack
            tagsTableController.panel.setTags(tags)
            tagsTableController.tagsSelectionDelegate = self
            self.navigationController?.pushViewController(tagsTableController, animated: true)
        })
        addFloatyItem(icon: UIImage(named: "notification")) {
            _ in
            self.notificationsManager.authorization()
            let notificationController = NotificationController()
            notificationController.locale = self.locale
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
    private func updateTagsHeight(view: TagsCloudCollectionView, minHeight: CGFloat) {
        let height = view.collectionViewLayout.collectionViewContentSize.height
        let constraint: NSLayoutConstraint!
        switch view {
        case customView.tagsView:
            constraint = customView.tagsViewHeight
        case customView.infoView:
            constraint = customView.infoViewHeight
        default:
            return
        }
        constraint.constant = height < minHeight ? minHeight : height
    }

    private func updateUI() {
        guard let note = note else {
            return
        }

        // title
        customView.titleView.text = note.title

        // text
        customView.noteView.text = note.text

        // background
        if let background = note.background {
            updateBackground(background: background)
        }

        // tags
        if let tags = note.tags as? Set<Tag> {
            tagsProvider.tags = Array(tags)
            updateTags()
        }
    }

    private func updateBackground(background: GradientBackgroud) {
        guard let layer = customView.noteView.layer as? CAGradientLayer else {
            return
        }
        let isLoaded = background.loadToLayer(layer: layer)
        if !isLoaded {
            customView.noteView.setupDefaultLayerParams()
        }
    }

    private func updateTags() {
        let manager = NoteTagsManager()
        manager.locale = locale

        var currentTags = manager.tagsWithoutTemp(tags: tagsProvider.tags)
        currentTags.sort(by: { $0.name ?? "" < $1.name ?? "" })

        let tagsWithNotification = manager.addNotificationTag(tags: currentTags, notifications: notifications)
        tagsProvider.tags = tagsWithNotification
        customView.tagsView.reloadData()
        customView.tagsView.isHidden = tagsWithNotification.count == 0 ? true : false
    }

    private func updateNoteInfo() {
        guard let note = note else {
            customView.infoView.isHidden = true
            return
        }
        let manager = NoteTagsManager()
        manager.locale = locale
        let tags = manager.infoTags(from: note)
        infoProvider.tags = tags
        customView.infoView.reloadData()
        customView.infoView.isHidden = tags.count == 0 ? true : false
    }
}

// MARK: Actions

extension NoteViewController {
    @objc private func doneTapped() {
        view.endEditing(true)
    }

    @objc private func paletteTapped() {
        let controller = NoteBackgroundController()
        controller.backgroundSelectionDelegate = self

        if let background = note?.background {
            controller.background = background
        } else if let layer = customView.noteView.layer as? CAGradientLayer {
            let background = GradientBackgroud.createFromLayer(layer: layer)
            controller.background = background
        }

        navigationController?.pushViewController(controller, animated: true)
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

// MARK: Keyboard notifications

extension NoteViewController {
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        customView.scrollView.contentInset = contentInset
        customView.floaty.isHidden = true
    }

    @objc private func keyboardWillHide(notification: Notification) {
        customView.scrollView.contentInset = UIEdgeInsets.zero
        customView.floaty.isHidden = false
    }
}

// MARK: TagsSelectionProtocol

extension NoteViewController: TagsSelectionProtocol {
    func tagsDidSelect(tags: [Tag]) {
        tagsProvider.tags = tags
        updateTags()
    }
}

// MARK: NoteNotificationsProtocol

extension NoteViewController: NoteNotificationsProtocol {
    func notificationsDidSet(notifications: Set<NoteNotification>) {
        self.notifications = notifications
        updateTags()
    }
}

// MARK: NoteBackgroundProtocol

extension NoteViewController: NoteBackgroundProtocol {
    func backgroundDidSet(background: GradientBackgroud) {
        updateBackground(background: background)
    }
}

// MARK: Core Data

extension NoteViewController {
    private func saveNote() {
        let note: Note = self.note ?? Note(context: coreDataStack.managedContext)

        let title: String = customView.titleView.text ?? ""
        if note.title != title { note.title = title }

        let text: String = customView.noteView.text ?? ""
        if note.text != text { note.text = text }

        saveBackground(note, layer: customView.noteView.layer as! CAGradientLayer)
        saveTags(note)
        let (addArr, remArr) = note.setNotifications(coreDataStack, notifications: notifications)
        coreDataStack.saveContext()

        notificationsManager.register(notifications: addArr)
        notificationsManager.deregister(ids: remArr)
    }

    private func saveBackground(_ note: Note, layer: CAGradientLayer) {
        let selectedBackground = GradientBackgroud.createFromLayer(layer: layer)
        note.setBackground(coreDataStack, background: selectedBackground)
    }

    private func saveTags(_ note: Note) {
        let selectedTagsArray = NoteTagsManager().tagsWithoutTemp(tags: tagsProvider.tags)
        note.setTags(coreDataStack, tags: Set(selectedTagsArray))
    }
}
