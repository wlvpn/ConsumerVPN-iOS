//
//  ProgressSpinnerHelper.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 22/05/24.
//  Copyright © 2024 NetProtect. All rights reserved.
//

import Foundation
import UIKit

class ProgressSpinnerHelper {
    static let shared = ProgressSpinnerHelper()
    
    private let spinnerView = ProgressSpinnerView()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func showSpinner(on view: UIView) {
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)
        
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinnerView.widthAnchor.constraint(equalToConstant: 60),
            spinnerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        spinnerView.show()
    }
    
    func hideSpinner() {
        spinnerView.hide()
        spinnerView.removeFromSuperview()
    }
    
    @objc private func appDidEnterBackground() {
        // Pause or stop the spinner animation
        spinnerView.stopAnimating()
    }
        
        @objc private func appWillEnterForeground() {
            // Resume or restart the spinner animation
            spinnerView.startAnimating()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
}
