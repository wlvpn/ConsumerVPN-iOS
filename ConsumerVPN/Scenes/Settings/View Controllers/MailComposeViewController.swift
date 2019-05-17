//  MailComposeViewController.swift
//  StrongVPN
//
//  Created by WLVPN on 4/10/18.
//  Copyright © 2018 NetProtect. All rights reserved.
//

import UIKit
import MessageUI

class MailComposeViewController: MFMailComposeViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
}
