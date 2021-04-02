//
//  AboutViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/20/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var explanationLabel1: UILabel!
    @IBOutlet weak var explanationLabel2: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    
    private let contactEmail = "partners@wlvpn.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        populateText()
    }
    
    private func configureView() {
        // Setup Colors
        versionLabel.textColor = .primaryFont
        explanationLabel1.textColor = .primaryFont
        explanationLabel2.textColor = .primaryFont
        view.backgroundColor = .viewBackground
        view.tintColor = .appWideTint
        
        // configure email address
        emailButton.setTitle(contactEmail, for: .normal)
    }
    
    private func populateText() {
        guard let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") else {return}
        guard let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") else {return}
        
        //TODO: Replace with localized string constant
        versionLabel.text = "Version \(versionNumber) (\(buildNumber))"
        versionLabel.textColor = .primaryFont
    }
    
    @IBAction func createEmail() {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([contactEmail])
            composeVC.setSubject("Hello from CloudFest VPN")
            composeVC.setMessageBody("", isHTML: false)
            present(composeVC, animated: true, completion: nil)
        } else {
            // User does not have email configured
            let alertC = UIAlertController(title: "Email Not Configured", message: "Your device has not been configured to send email.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertC.addAction(okButton)
            present(alertC, animated: true, completion: nil)
        }
    }
}

extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
