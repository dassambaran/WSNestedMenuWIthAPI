//
//  Loader.swift
//
//  Created by SD on 01/07/20.
//  Copyright © 2020 SD. All rights reserved.
//

import Foundation
import UIKit

class Loader: NSObject {
    static let shared = Loader()
    private var alert: UIAlertController?
    private var message = "Please wait..."
    private var tempMessage = "Please wait..."
    override init() {
        alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert?.view.addSubview(loadingIndicator)
    }
    func addIndicator() {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert?.view.addSubview(loadingIndicator)
    }
    
    func show(_ progress: Int)  {
        self.message = tempMessage
        self.message = "\(message) \(progress)%"
        self.alert?.message = message
    }
    
    func showLoader()  {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.alert = nil
            self.alert = UIAlertController(title: nil, message: self.message, preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();

            self.alert?.view.addSubview(loadingIndicator)
            UIApplication.shared.keyWindow?.rootViewController?.present(self.alert!, animated: true, completion: nil)
        }
    }
    
    func hideLoader()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                self.alert?.dismiss(animated: true, completion: nil)
        }
    }
}
