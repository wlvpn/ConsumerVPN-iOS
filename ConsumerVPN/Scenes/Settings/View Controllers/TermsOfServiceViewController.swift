//
//  TermsOfServiceViewController.swift
//  CloudFest VPN
//
//  Created by WLVPN on 3/11/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .viewBackground
        title = "Terms of Service"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadWebview()
    }
    
    func loadWebview() {
        let htmlURL = Bundle.main.path(forResource: "tos", ofType: "html")
        do {
            let contents = try String(contentsOfFile: htmlURL!, encoding: String.Encoding.utf8)
            webView.loadHTMLString(contents, baseURL: Bundle.main.bundleURL)
        } catch {
            print("There was an error loading the webview")
        }
    }
}

extension TermsOfServiceViewController: UIWebViewDelegate {
    
    /// This will open an external web browser whenever a link is selected.
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == UIWebView.NavigationType.linkClicked {
            UIApplication.shared.open(request.url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            return false
        }
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
