//  DiagnosticsViewController.swift
//  Consumer VPN
//
//  Created by WLVPN on 4/9/18.
//  Copyright © 2019 StackPath, LLC. All rights reserved.
//

import UIKit

class DiagnosticsViewController: UIViewController {

    @IBOutlet weak var diagnosticsTextView: UITextView!
    @IBOutlet weak var diagnosticsLevelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var diagnosticsDescriptionLabel: UILabel!
    @IBOutlet weak var diagnosticsAdvancedDescriptionLabel: UILabel!

    private enum DiagnosticsViewState {
        case loggingOff
        case loggingOnEmpty
        case loggingOnWithContent(String)
    }

    private let diagnosticsService = DiagnosticsService()
    private let deviceInfoContainerView = UIView()
    private let deviceInfoLabel = UILabel()
    private lazy var shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareDiagnosticData(_:)))
    private lazy var deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashCanTapped(_:)))

    var accountName: String?
    var diagContent: String?
    
    var apiManager: VPNAPIManager!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		apiManager = AppDelegate.sharedDelegate().apiManager

        navigationItem.rightBarButtonItems = [shareBarButtonItem, deleteBarButtonItem]
        configureLocalizedText()
        configureDeviceInfoView()
        loadDiagnosticData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadDiagnosticData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction private func logLevelChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            diagnosticsService.setLogLevel(.off)
            diagnosticsService.clearLogs()
        case 1:
            diagnosticsService.setLogLevel(.error)
        default:
            diagnosticsService.setLogLevel(.debug)
        }

        loadDiagnosticData()
    }
    
    // Updated to use system share sheet instead of mail composer to comply with requirement
    @objc private func shareDiagnosticData(_ sender: UIBarButtonItem) {
        guard let diagText = diagContent, diagText.count > 0 else { return }

        do {
            let fileURL = try diagnosticsService.makeShareFile(withLogContent: diagText)
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { [diagnosticsService] _, _, _, _ in
                diagnosticsService.removeShareFile(at: fileURL)
            }
            activityViewController.popoverPresentationController?.barButtonItem = sender
            present(activityViewController, animated: true, completion: nil)
        } catch {
            let alertVC = UIAlertController.alert(withTitle: LocalizedString.diagnosticsNotSharedTitle, message: LocalizedString.diagnosticsNotSharedMessage, actions: [UIAlertAction(title: LocalizedString.ok, style: .default, handler: nil)], alertType: .alert)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    @objc private func trashCanTapped(_ sender: UIBarButtonItem) {
        confirmRemoveDiagnosticData()
    }
    
    // MARK: - Private functions
    
    private func configureLocalizedText() {
        title = LocalizedString.diagnosticsTitle
        diagnosticsDescriptionLabel.text = LocalizedString.diagnosticsDescription
        diagnosticsAdvancedDescriptionLabel.text = LocalizedString.diagnosticsAdvancedDescription
        diagnosticsLevelSegmentedControl.setTitle(LocalizedString.diagnosticsLogLevelOff, forSegmentAt: 0)
        diagnosticsLevelSegmentedControl.setTitle(LocalizedString.diagnosticsLogLevelNormal, forSegmentAt: 1)
        diagnosticsLevelSegmentedControl.setTitle(LocalizedString.diagnosticsLogLevelAdvanced, forSegmentAt: 2)
    }

    private func configureDeviceInfoView() {
        deviceInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        deviceInfoContainerView.backgroundColor = UIColor.viewBackground.lighter
        deviceInfoContainerView.layer.cornerRadius = 6
        deviceInfoContainerView.clipsToBounds = true

        deviceInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceInfoLabel.numberOfLines = 0
        deviceInfoLabel.font = UIFont.systemFont(ofSize: 12)
        deviceInfoLabel.textColor = .settingsFont

        view.addSubview(deviceInfoContainerView)
        deviceInfoContainerView.addSubview(deviceInfoLabel)

        let diagnosticsTextTopConstraint = view.constraints.first { constraint in
            return constraint.firstItem === diagnosticsTextView && constraint.firstAttribute == .top
        }
        diagnosticsTextTopConstraint?.isActive = false

        NSLayoutConstraint.activate([
            deviceInfoContainerView.leadingAnchor.constraint(equalTo: diagnosticsTextView.leadingAnchor),
            deviceInfoContainerView.trailingAnchor.constraint(equalTo: diagnosticsTextView.trailingAnchor),
            deviceInfoContainerView.topAnchor.constraint(equalTo: diagnosticsAdvancedDescriptionLabel.bottomAnchor, constant: 12),

            deviceInfoLabel.leadingAnchor.constraint(equalTo: deviceInfoContainerView.leadingAnchor, constant: 10),
            deviceInfoLabel.trailingAnchor.constraint(equalTo: deviceInfoContainerView.trailingAnchor, constant: -10),
            deviceInfoLabel.topAnchor.constraint(equalTo: deviceInfoContainerView.topAnchor, constant: 8),
            deviceInfoLabel.bottomAnchor.constraint(equalTo: deviceInfoContainerView.bottomAnchor, constant: -8),

            diagnosticsTextView.topAnchor.constraint(equalTo: deviceInfoContainerView.bottomAnchor, constant: 12)
        ])
    }

    private func loadDiagnosticData() {
        let diagLevel = diagnosticsService.logLevel()
		diagnosticsLevelSegmentedControl.selectedSegmentIndex = selectedSegmentIndex(for: diagLevel)
        diagContent = nil
        deviceInfoLabel.text = diagnosticsService.deviceInfo().formattedText

        render(state: diagnosticsViewState(for: diagLevel))
    }

    private func diagnosticsViewState(for logLevel: VPNLogLevel) -> DiagnosticsViewState {
        guard logLevel != .off else { return .loggingOff }

        if let content = diagnosticsService.loadLogContent() {
            return .loggingOnWithContent(content)
        }

        return .loggingOnEmpty
    }

    private func render(state: DiagnosticsViewState) {
        switch state {
        case .loggingOff:
            diagnosticsTextView.text = LocalizedString.diagnosticsLoggingDisabled
            setActionButtonsVisible(false)
        case .loggingOnEmpty:
            diagnosticsTextView.text = LocalizedString.diagnosticsNoData
            setActionButtonsVisible(true)
            setActionButtonsEnabled(false)
        case .loggingOnWithContent(let content):
            diagContent = content
            diagnosticsTextView.text = content
            setActionButtonsVisible(true)
            setActionButtonsEnabled(true)
        }
    }

    private func setActionButtonsVisible(_ isVisible: Bool) {
        navigationItem.rightBarButtonItems = isVisible ? [shareBarButtonItem, deleteBarButtonItem] : nil
        setActionButtonsEnabled(isVisible)
    }

    private func setActionButtonsEnabled(_ isEnabled: Bool) {
        shareBarButtonItem.isEnabled = isEnabled
        deleteBarButtonItem.isEnabled = isEnabled
    }

    private func selectedSegmentIndex(for logLevel: VPNLogLevel) -> Int {
        switch logLevel {
        case .off:
            return 0
        case .error:
            return 1
        default:
            return 2
        }
    }

    private func confirmRemoveDiagnosticData() {
        let alertVC = UIAlertController(title: LocalizedString.diagnosticsDeleteTitle, message: LocalizedString.diagnosticsDeleteMessage, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: LocalizedString.delete, style: .destructive) { [weak self] _ in
            self?.removeDiagnosticData()
        }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)

        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)

        present(alertVC, animated: true, completion: nil)
    }
    
    private func removeDiagnosticData() {
        diagnosticsService.clearLogs()
        loadDiagnosticData()
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
