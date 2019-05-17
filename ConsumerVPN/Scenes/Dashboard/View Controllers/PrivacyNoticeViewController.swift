//
//  PrivacyNoticeViewController.swift
//  Consumer VPN
//
//  Created by WLVPN on 3/4/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

protocol PrivacyNoticeDelegate {
    func userDidAgree()
}

final class PrivacyNoticeViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var p1Label: UILabel!
    @IBOutlet private weak var p2Label: UILabel!
    @IBOutlet private weak var p3Label: UILabel!
    @IBOutlet private weak var p4Label: UILabel!
    
    @IBOutlet weak var agreeButton: UIButton!
    
    var delegate: PrivacyNoticeDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    private func configureView() {
        
        // View wide settings
        view.backgroundColor = .viewBackground
        titleLabel.tintColor = .appWideTint
        let fontSize: CGFloat = 15
        let regularTextColor = UIColor(white: 0.9, alpha: 1.0)
        
        // Attributes for regular and highlighted text
        let regularAttributes = [NSAttributedString.Key.foregroundColor: regularTextColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]

        
        // Paragraph 1
        p1Label.attributedText = NSAttributedString(string: "WLVPN cares about our users privacy. That's why it's important we're clear about what you consent to give us while using CloudFest VPN. We collect a small amount of personal and anonymously-aggregated data to deliver a reliable VPN service, specifically:", attributes: regularAttributes)
        
        // Paragrah 2
        let p21 = NSAttributedString(string: "• Your email address", attributes: regularAttributes)
        let p22 = NSAttributedString(string: "• Aggregated crash reports", attributes: regularAttributes)
        let p23 = NSAttributedString(string: "• Aggregated device information", attributes: regularAttributes)

        let p2Combined = NSMutableAttributedString()
        p2Combined.append(p21)
        p2Combined.append(p22)
        p2Combined.append(p23)
        p2Label.attributedText = p2Combined
        
        // Paragraph 3
        p3Label.attributedText = NSAttributedString(string: "Additionally, as this free VPN service is only available to CloudFest attendees, we may share your email address with WorldHostingDays GmbH (\"CloudFest\") to determine your eligibility and share further information on WLVPN. You will always be able to opt-out of these emails.", attributes: regularAttributes)
        
        // Agree Button
        agreeButton.tintColor = .appWideTint
        agreeButton.layer.cornerRadius = 8.0
        agreeButton.layer.borderWidth = 2.0
        agreeButton.layer.borderColor = UIColor.appWideTint.cgColor
        
    }
    
    @IBAction private func agreeToTerms(_ sender: UIButton) {
        delegate?.userDidAgree()
    }
}

extension PrivacyNoticeViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return "Dashboard"
    }
    
    class func build(with delegate: PrivacyNoticeDelegate) -> PrivacyNoticeViewController {
        let privacyVC = instantiate(with: "PrivacyNoticeViewController")
        privacyVC.delegate = delegate
        return privacyVC
    }
}
