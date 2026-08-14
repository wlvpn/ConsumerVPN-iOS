//
//  OpenVPNSettingsViewController.swift
//  ConsumerVPN
//
//  Created by Hitesh on 29/04/25.
//  Copyright © 2025 NetProtect. All rights reserved.
//

import UIKit
import VPNKit

class OpenVPNSettingsViewController: UIViewController {

    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var labelProtocol: UILabel!
    @IBOutlet weak var labelPort: UILabel!
    @IBOutlet weak var swScramble: UISwitch!
    
    private var openVPNSettings: VPNOpenVPNSettings? { ApiManagerHelper.shared.vpnConfiguration.openVPNSettings }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .viewBackground
        
        for label in labels {
            label.textColor = .settingsFont
        }
        
        labelProtocol.textColor = .settingsFont
        labelPort.textColor = .settingsFont
        
        swScramble.thumbTintColor = UIColor.primaryText
        swScramble.onTintColor = UIColor.secondaryText

        labelProtocol.text = "TCP"
        labelPort.text = "443"
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let port = openVPNSettings?.port {
            labelPort.text = String(port)
        }
        
        if ApiManagerHelper.shared.vpnConfiguration.openVPNSettings.protocol == .TCP {
            
            labelProtocol.text = "TCP"
        }
        else {
            labelProtocol.text = "UDP"
        }
        
        swScramble.setOn(openVPNSettings?.scramble ?? false, animated: true)
    }
    
    @IBAction func showProtocolSelectionAlert(_ sender: Any) {
        
        guard !isDisplayingDisconnectAlert() else {
            return
        }
        
        let alertVC = UIAlertController(title: "OpenVPN Protocol Type", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "TCP", style: .default, handler: { [weak self] _ in
            self?.labelProtocol.text = "TCP"
            self?.updateOpenVPNProtocol(.TCP)
        }))
        alertVC.addAction(UIAlertAction(title: "UDP", style: .default, handler: { [weak self] _  in
            self?.labelProtocol.text = "UDP"
            self?.updateOpenVPNProtocol(.UDP)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func showPortSelectionAlert(_ sender: Any) {
        
        guard !isDisplayingDisconnectAlert() else {
            return
        }
        
        guard let availablePorts = openVPNSettings?.availablePorts() else {
            return
        }
        
        if availablePorts.count > 0 {
            let alertVC = UIAlertController(title: "OpenVPN Port", message: nil, preferredStyle: .alert)
            
            for port in availablePorts {
                alertVC.addAction(UIAlertAction(title: port.stringValue, style: .default, handler: { [weak self] _ in
                    self?.labelPort.text = port.stringValue
                    self?.updateOpenVPNPort(port.uintValue)
                }))
            }
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func didTapOnScrambleEnabled(_ sender: UISwitch) {
        
        guard !isDisplayingDisconnectAlert() else {
            sender.setOn(!sender.isOn, animated: true)
            return
        }
        
        openVPNSettings?.scramble = sender.isOn
        
        if let port = self.openVPNSettings?.port {
            self.labelPort.text = String(port)
        }
        
    }
    
    private func updateOpenVPNPort(_ port: UInt) {
        ApiManagerHelper.shared.updateOpenVPNPort(port)
    }
    
    private func updateOpenVPNProtocol(_ vpnprotocol: OpenVPNProtocolType) {
        ApiManagerHelper.shared.vpnConfiguration.openVPNSettings.protocol = vpnprotocol
    }
    
    private func isDisplayingDisconnectAlert() -> Bool {
        if ApiManagerHelper.shared.isSafeToChangeConfiguration() {
            return false
        }
        else
        {
            let alertVC = UIAlertController(title: "VPN Connected", message: "Currently connected to VPN, Please disconnect to change the settings", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alertVC, animated: true, completion: nil)
            
            return true
        }
    }
}
