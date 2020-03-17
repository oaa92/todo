//
//  Toast.swift
//  todo
//
//  Created by Анатолий on 17/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import UIKit

class ToastManager {
    private var toast: ToastView?

    private func create(message: String, image: UIImage? = nil) -> ToastView {
        let toast = ToastView()
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.imageView.isHidden = image == nil ? true : false
        toast.imageView.image = image
        toast.label.text = message
        return toast
    }

    func show(message: String, image: UIImage? = nil, controller: UIViewController) {
        toast?.removeFromSuperview()
        let toast = create(message: message, image: image)
        self.toast = toast

        controller.view.addSubview(toast)
        let toastConstrains = [toast.heightAnchor.constraint(equalToConstant: 50),
                               toast.leadingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.leadingAnchor),
                               toast.trailingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.trailingAnchor),
                               toast.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(toastConstrains)
        toast.layoutIfNeeded()
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toast.alpha = 0.0
            toast.layoutIfNeeded()
        }, completion: { _ in
            toast.removeFromSuperview()
        })
    }
}
