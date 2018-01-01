//
//  ViewController.swift
//  SwiftyStreethawkDemo
//
//  Created by Xingyuji on 30/12/17.
//  Copyright © 2017 com.xingyuji. All rights reserved.
//

import UIKit
import SHSdkSwift

class ViewController: UIViewController {

    @IBOutlet weak var tagkey: UITextField!
    @IBOutlet weak var tagvalue: UITextField!
    @IBOutlet weak var host: UILabel!
    @IBOutlet weak var appKey: UILabel!
    @IBOutlet weak var sysLog: UITextView!
    @IBOutlet weak var installid: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sysLog.isScrollEnabled = true
        sysLog.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
        let range = NSMakeRange(self.sysLog.text.utf8CString.count - 1, 0)
        self.sysLog.scrollRangeToVisible(range)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollToEnd(_ someTextView:UITextView) {
        let bottom = NSMakeRange(someTextView.text.lengthOfBytes(using: .utf8)-1, 1)
        someTextView.scrollRangeToVisible(bottom)
    }
    
    @IBAction func sendLoglineTag(_ sender: Any) {
        let content = ["key": tagkey.text!, "string": tagvalue.text!]
        self.sysLog.text! += "tagging via logline..."
        SHClientsManager.shProcessor?.tagViaLogline(content) { res in
            self.sysLog.text! += "done, return: \(String(describing: res)) \n"
        }
    }
    
    @IBAction func flushBuffer(_ sender: Any) {
        SHClientsManager.shProcessor?.flushBuffer(){ res in
            self.sysLog.text! += "flushBuffer, return: \(String(describing: res)) \n"
        }
    }
    
    @IBAction func sendApiTag(_ sender: Any) {
        let content = ["key": tagkey.text!, "string": tagvalue.text!]
        self.sysLog.text! += "tagging via api..."
        SHClientsManager.shProcessor?.tagViaApi(content, authToken: "1JMyBIGTLLA86MxJ7nCm7kBZoSiOmJ"){ res in
            self.sysLog.text! += "done, return: \(String(describing: res)) \n"
        }
    }
    
    @IBAction func completeActivity(_ sender: Any) {
        SHClientsManager.shProcessor?.simulateNormalLogline("completeActivity")
        self.sysLog.text! += "add a completeActivity logline to buffer \n"
    }
    
    @IBAction func acceptPush(_ sender: Any) {
        SHClientsManager.shProcessor?.simulateNormalLogline("acceptPush")
        self.sysLog.text! += "add an acceptPush logline to buffer \n"
    }
    
    @IBAction func upgradeClient(_ sender: Any) {
        SHClientsManager.shProcessor?.simulateNormalLogline("upgradeClient")
        self.sysLog.text! += "add a upgradeClient logline to buffer \n"
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

