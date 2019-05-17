//  DiagnosticsViewController.swift
//  Consumer VPN
//
//  Created by WLVPN on 4/9/18.
//  Copyright © 2019 StackPath, LLC. All rights reserved.
//

import UIKit
import MessageUI

class DiagnosticsViewController: UIViewController {

    @IBOutlet weak var diagnosticsTextView: UITextView!
    @IBOutlet weak var diagnosticsLevelSegmentedControl: UISegmentedControl!
    
    var accountName: String?
    var diagContent: String?
    
    var apiManager: VPNAPIManager!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		apiManager = AppDelegate.sharedDelegate().apiManager
		
        loadDiagnosticData()
        title = "Diagnostics"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareDiagnosticData(_:))), UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashCanTapped(_:)))]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadDiagnosticData()
		let logLevel = apiManager.logLevel()
		
        switch logLevel{
        case .off:
            self.diagnosticsLevelSegmentedControl.selectedSegmentIndex = 0
        case .error:
            self.diagnosticsLevelSegmentedControl.selectedSegmentIndex = 1
        default:
            self.diagnosticsLevelSegmentedControl.selectedSegmentIndex = 2
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction private func logLevelChanged(_ sender: UISegmentedControl) {
        if let apiManager = AppDelegate.sharedDelegate().apiManager {
            switch sender.selectedSegmentIndex {
            case 0:
                apiManager.setLogLevel(.off)
                promptForDeleteIfNecessary()
            case 1:
                apiManager.setLogLevel(.error)
            default:
                apiManager.setLogLevel(.debug)
            }
			
			loadDiagnosticData()
        }
    }
    
    @objc private func shareDiagnosticData(_ sender: UIBarButtonItem) {
        guard let diagText = diagnosticsTextView.text, diagText.count > 0 else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MailComposeViewController(nibName: nil, bundle: nil)
            mailVC.mailComposeDelegate = self
            mailVC.navigationBar.tintColor = UIColor.white
            mailVC.setToRecipients(["support@wlvpn.com"])
            mailVC.setSubject("WLVPN Support Diagnostics")
            
            guard let messageBody = formatDiagnosticsEmailContent() else { return }
            mailVC.setMessageBody(messageBody, isHTML: false)
            
            guard let data = diagText.data(using: .utf8) else { return }
            guard let filename = generateFileName() else { return }
            mailVC.addAttachmentData(data, mimeType: "text/plain", fileName: filename)
            if let serverListData = loadServerListIfExists() {
                mailVC.addAttachmentData(serverListData, mimeType: "application/json", fileName: kV3ServerListFileKey)
            }
            
            present(mailVC, animated: true, completion: nil)
        }
    }
    
    @objc private func trashCanTapped(_ sender: UIBarButtonItem) {
        removeDiagnosticData()
    }
    
    // MARK: - Private functions
    
    private func loadDiagnosticData() {
        let diagLevel = UserDefaults.standard.integer(forKey: kVPNCurrentLogLevel)
        diagnosticsLevelSegmentedControl.selectedSegmentIndex = diagLevel
        
        // Assume no log data available, and textview.text will be replaced below if
        // log data does exist.
        diagnosticsTextView.text = "No diagnostics data to display."
        
        if let logPath = apiManager.logFile() {
            if let content = try? String(contentsOfFile: logPath),
                content != "" {
                diagContent = content
                diagnosticsTextView.text = diagContent
            }
        }
    }
    
    private func generateFileName() -> String? {
        var filename: String?
        guard let infoDict = Bundle.main.infoDictionary, let version = infoDict["CFBundleShortVersionString"] else { return nil }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: Date())
        filename = "\(dateString)-WLVPN-iOS-\(version).log"
        return filename
    }
    
    private func promptForDeleteIfNecessary() {
        if let _ = diagContent {
            let alertVC = UIAlertController(title: "Remove Diagnostics Data", message: "Diagnostics are disabled. Would you like to remove existing diagnostics data?", preferredStyle: .alert)
            let removeAction = UIAlertAction(title: "Remove Data", style: .destructive) { _ in
                self.removeDiagnosticData()
            }
            alertVC.addAction(removeAction)
            let keepAction = UIAlertAction(title: "Keep Data", style: .cancel, handler: nil)
            alertVC.addAction(keepAction)
            
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    private func formatDiagnosticsEmailContent() -> String? {
        guard let infoDict = Bundle.main.infoDictionary, let version = infoDict["CFBundleShortVersionString"] else { return nil }
        let df = DateFormatter()
        df.dateFormat = "MMM-dd-yyy h:mm a zzz"
        let dateString = df.string(from: Date())
        return "CloudFest VPN for iOS\nVersion: \(version)\nDiagnostics generated: \(dateString)"
    }
    
    private func removeDiagnosticData() {
        apiManager.clearLogs()
        loadDiagnosticData()
    }
    
    @objc private func loadServerListIfExists() -> Data? {
        
        if let apiAdapter = apiManager.apiAdapter as? V3APIAdapter,
            let coreDataURL = apiAdapter.getOption(kV3CoreDataURL) as? URL {
            let serverListURL = coreDataURL.deletingLastPathComponent().appendingPathComponent(kV3ServerListFileKey)
            do {
                let data = try Data(contentsOf: serverListURL)
                return data
            } catch {
            }
        }
        return nil
    }
}

extension DiagnosticsViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        switch result {
        case .sent, .saved, .cancelled:
            break
        case .failed:
            let alertVC = UIAlertController.alert(withTitle: "Diagnostics Not Sent", message: "The diagnostics email failed to send.", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)], alertType: .alert)
            present(alertVC, animated: true, completion: nil)
		default:
			break
        }
    }
}

// MARK: - StoryboardInstantiable
extension DiagnosticsViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        return "Main"
    }
    
    class func build(with apiManager: VPNAPIManager) -> DiagnosticsViewController {
        let diagVC = instantiate(with: "DiagnosticsViewController")
        diagVC.apiManager = apiManager
        return diagVC
    }
}
