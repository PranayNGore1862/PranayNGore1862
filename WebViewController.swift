//
//  WebViewController.swift
//  Boom Music
//
//  Created by Nikhil on 31/12/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var topLabel: UILabel!
    
    var topText = ""
    var urlString = ""
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var SetHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetTopBarHeight(constraint: SetHeight)
        topLabel.text = topText
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
