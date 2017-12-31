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
    
    @IBAction func sendLoglineTag(_ sender: Any) {
        let content = ["key": tagkey.text!, "string": tagvalue.text!]
        self.sysLog.text = "tagging via logline..."
        SHClientsManager.shProcessor?.tagViaLogline(content)
    }

    @IBAction func sendApiTag(_ sender: Any) {
        let content = ["key": tagkey.text!, "string": tagvalue.text!]
        self.sysLog.text = "tagging via api..."
        SHClientsManager.shProcessor?.tagViaApi(content, authToken: "1JMyBIGTLLA86MxJ7nCm7kBZoSiOmJ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appKey.text = "hipointX"

        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

