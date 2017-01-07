//
//  ViewController.swift
//  MobyDick
//
//  Created by Ana Ma on 1/6/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, UITextFieldDelegate {
    var webView: WKWebView!
    var divColors = ["red", "green", "purple", "blue"]
    
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        self.inputTextField.delegate = self
        
        let path = Bundle.main.path(forResource: "embedded", ofType: "html")
        let dir = URL(fileURLWithPath: Bundle.main.bundlePath)
        let myURL = URL(fileURLWithPath: path!)
        webView.loadFileURL(myURL, allowingReadAccessTo: dir)
    }
    
    private func setupWebView() {
        // Setup userScript
        //let source = "document.body.style.background = \"#FFFFFF\";"
        //let source = "document.body.style.background = \"#777\";"
        let source = "document.body.findText();"
        // Using 
        // w3schools.com/getelementbyclassname
        // <h1 class="hero-headline">This is 7.</h1>
        // let source = "document.getElementsByClassName('hero-headline').innerHTML = 'Vic is Vic, Cris is Chris';";
    let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    
        
        // User Content Controller
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        // self conforms to protocol WKScriptMessageHandler
        userContentController.add(self, name: "runSwift")
        
        // Webconfiguration
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        //webView.navigationDelegate = self
        
        if let containerView = view.viewWithTag(1) {
            containerView.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            webView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            webView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        }
    }
    @IBAction func colorChosen(_ sender: UISegmentedControl) {
        let color = divColors[sender.selectedSegmentIndex]
        
        var js = "document.getElementById('box1').style.backgroundColor = '\(color)';";
        js += "document.getElementById('box1').innerHTML = '\(color)'; "
        js += "findText();"
        webView.evaluateJavaScript(js) { (ret, error) in
            print(ret ?? "whoops")
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received message named: \(message.name)")
        print(message.body)
        
        if let msg = message.body as? [String:Any] {
            print(msg["myColor"] ?? "whoops")
            inputTextField.text = msg["myColor"] as? String
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case inputTextField:
            guard let validText = inputTextField.text else { return }
            
            var js = "document.getElementById('box2').style.backgroundColor = '\(validText)';";
            js += "document.getElementById('box2').innerHTML = '\(validText)'"
            webView.evaluateJavaScript(js) { (ret, error) in
                print(ret ?? "whoops")
            }

            print(inputTextField.text ?? "")
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing(textField)
        return true
    }
    
    @IBAction func rewindBarButtonTapped(_ sender: UIBarButtonItem) {
        self.webView.goBack()
    }
    
    @IBAction func fastForwardBarButtonTapped(_ sender: UIBarButtonItem) {
        self.webView.goForward()
    }
    
    //add texfield add content to the div, add back button to get to previous screen, add forward to get the future screen
}
