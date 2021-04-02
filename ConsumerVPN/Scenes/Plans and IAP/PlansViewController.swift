//
//  PlansViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 27/03/20.
//  Copyright © 2020 NetProtect. All rights reserved.
//

import UIKit

protocol PlansViewControllerDelegate {
	func userDidSelect(plan: Plan, username: String, password: String?, from controller: UIViewController)
}

class PlansViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Properties
	
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var upgradeToLabel: UILabel!
	@IBOutlet weak var premiumLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var bulletImage1: UIImageView!
	@IBOutlet weak var bulletImage2: UIImageView!
	@IBOutlet weak var bulletImage3: UIImageView!
	@IBOutlet weak var bulletLabel1: UILabel!
	@IBOutlet weak var bulletLabel2: UILabel!
	@IBOutlet weak var bulletLabel3: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var disclosureText: UILabel!
    @IBOutlet weak var emptyStateLabel: UILabel!
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .loginStatusBar
	}
	
	var delegate: PlansViewControllerDelegate!
	
	var credentials: (String, String?)!
	
	var plans = [Plan]() {
		didSet {
            let empty = plans.count == 0
            updateViewsState(empty: empty)
            tableView?.reloadData()
		}
	}
	
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()        
		configureView()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setNeedsStatusBarAppearanceUpdate()
		tableView.reloadData()
	}
	
	
	// MARK: - Additional UI
	
	private func configureView() {
		drawGradient()
		
		closeButton.tintColor = .appWideTint
		
		upgradeToLabel.textColor = .iapPrimaryFontColor
		premiumLabel.textColor = .iapSecondaryFontColor
		
		descriptionLabel.text = Theme.plansDescription
		descriptionLabel.textColor = .iapPrimaryFontColor
		
		bulletImage1.tintColor = .appWideTint
		bulletImage2.tintColor = .appWideTint
		bulletImage3.tintColor = .appWideTint
		
		bulletLabel1.text = Theme.plansBullet1
		bulletLabel1.textColor = .iapPrimaryFontColor
		
		bulletLabel2.text = Theme.plansBullet2
		bulletLabel2.textColor = .iapPrimaryFontColor
		
		bulletLabel3.text = Theme.plansBullet3
		bulletLabel3.textColor = .iapPrimaryFontColor
		
		disclosureText.textColor = .iapPrimaryFontColor
	}
	
	
	private func drawGradient() {
		// Background gradient layer
		let gradient = CAGradientLayer()
		gradient.frame = view.frame
		gradient.colors = [UIColor.iapViewGradientTop.cgColor, UIColor.iapViewGradientMid.cgColor, UIColor.iapViewGradientBottom.cgColor]
		gradient.startPoint = CGPoint.zero
		gradient.endPoint = CGPoint(x: 0.15, y: 0.9)
		view.layer.insertSublayer(gradient, at: 0)
	}
    
    fileprivate func updateViewsState(empty: Bool) {
        tableView.isHidden = empty
        bulletImage1.isHidden = empty
        bulletImage2.isHidden = empty
        bulletImage3.isHidden = empty
        
        bulletLabel1.isHidden = empty
        bulletLabel2.isHidden = empty
        bulletLabel3.isHidden = empty
        
        descriptionLabel.isHidden = empty
        disclosureText.isHidden = empty
        
        emptyStateLabel.isHidden = !empty
    }
	
	
	// MARK: - Actions
	
	@IBAction func closeButtonTapped(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
}


extension PlansViewController {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return plans.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PlanTableViewCell", for: indexPath) as! PlanTableViewCell
		
		// TODO: Properly load all plans based on self.plans
		let plan = plans[indexPath.row]
		cell.planTitle.text = plan.localizedTitle
		cell.planSubtitle.text = plan.localizedSubtitle
		cell.price.text = "\(plan.price)"
		
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		delegate.userDidSelect(plan: plans[indexPath.row], username: credentials.0, password: credentials.1, from: self)
        UIView.animate(withDuration: 0.2) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
	}
}

extension PlansViewController: StoryboardInstantiable {
	
	static var storyboardName: String {
		return "Plans"
	}
	
	class func build(delegate: PlansViewControllerDelegate, username: String, password: String?) -> PlansViewController {
		let vc = instantiateInitial()
		vc.delegate = delegate
		vc.credentials = (username, password)
		return vc
	}
}
