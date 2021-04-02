//
//  PrivacyNoticeViewController.swift
//  Consumer VPN
//
//  Created by WLVPN on 3/4/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

protocol PrivacyNoticeDelegate {
	func userDidAgree(username: String, password: String?, in controller: UIViewController)
}

final class PrivacyNoticeViewController: UIViewController {
	
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var p1Label: UILabel!
	@IBOutlet private weak var p2Label: UILabel!
	@IBOutlet private weak var p3Label: UILabel!
	@IBOutlet private weak var p4Label: UILabel!
	
	@IBOutlet weak var agreeButton: UIButton!
	
	var delegate: PrivacyNoticeDelegate?
	var credentials: (String, String?)!
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .dashboardStatusBar
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setNeedsStatusBarAppearanceUpdate()
	}
	
	private func configureView() {
		
		// View wide settings
		view.backgroundColor = .viewBackground
		titleLabel.textColor = .appWideTint
		let fontSize: CGFloat = 15
		let regularTextColor: UIColor = .primaryText
		
		// Attributes for regular and highlighted text
		let regularAttributes = [NSAttributedString.Key.foregroundColor: regularTextColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]
		
		
		// Paragraph 1
		p1Label.attributedText = NSAttributedString(string: Theme.privacyP1, attributes: regularAttributes)
		
		// Paragrah 2
		p2Label.attributedText = NSAttributedString(string: Theme.privacyP2, attributes: regularAttributes)
		
		// Paragraph 3
		p3Label.attributedText = NSAttributedString(string: Theme.privacyP3, attributes: regularAttributes)
		
		// Paragraph 4
		p4Label.attributedText = NSAttributedString(string: Theme.privacyP4, attributes: regularAttributes)
		
		// Agree Button
		agreeButton.setTitleColor(.connectButtonText, for: .normal)
		agreeButton.tintColor = .connectButtonText
		agreeButton.backgroundColor = .connectButtonBg
		agreeButton.layer.cornerRadius = 8.0
		agreeButton.layer.borderWidth = 2.0
		agreeButton.layer.borderColor = UIColor.connectButtonBorder.cgColor
		
	}
	
	@IBAction private func agreeToTerms(_ sender: UIButton) {
		delegate?.userDidAgree(username: credentials.0, password: credentials.1, in: self)
	}
}

extension PrivacyNoticeViewController: StoryboardInstantiable {
	static var storyboardName: String {
		return "Dashboard"
	}
	
	class func build(with delegate: PrivacyNoticeDelegate, username: String, password: String?) -> PrivacyNoticeViewController {
		let privacyVC = instantiate(with: "PrivacyNoticeViewController")
		privacyVC.delegate = delegate
		privacyVC.credentials = (username, password)
		return privacyVC
	}
}
