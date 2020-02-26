//
//  NotificationView.swift
//  todo
//
//  Created by Анатолий on 22/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        
        return stack
    }()
    
    let notificationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    let notificationSwitchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = UIColor.Palette.blue_soft.get
        switchView.setContentHuggingPriority(.required, for: .horizontal)
        return switchView
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.textColor = .systemBlue
        label.alpha = 0
        return label
    }()
    
    let periodStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.alpha = 0
        return stack
    }()
    
    let periodSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = "Повторять"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let periodSwitchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = UIColor.Palette.blue_soft.get
        switchView.setContentHuggingPriority(.required, for: .horizontal)
        return switchView
    }()
    
    let periodLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.textColor = .systemBlue
        label.alpha = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor.Palette.grayish_orange.get
        setupNotificationSwitchStack()
        stackView.addArrangedSubview(dateLabel)
        periodStack.addArrangedSubview(periodSwitchLabel)
        periodStack.addArrangedSubview(periodSwitchView)
        stackView.addArrangedSubview(periodStack)
        stackView.addArrangedSubview(periodLabel)
        scrollView.addSubview(stackView)
        addSubview(scrollView)
    }
    
    private func setupNotificationSwitchStack() {
        let label = UILabel()
        label.text = "Напоминать"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        notificationStack.addArrangedSubview(label)
        notificationStack.addArrangedSubview(notificationSwitchView)
        stackView.addArrangedSubview(notificationStack)
    }
    
    private func setupConstrains() {
        let scrollViewConstrains = [scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                                    scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                                    scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                                    scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(scrollViewConstrains)
        
        let stackViewConstrains = [stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                                   stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                                   stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                                   stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                                   stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)]
        NSLayoutConstraint.activate(stackViewConstrains)
    }
}
