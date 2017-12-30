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
    
    @IBAction func sendLoglineTag(_ sender: Any) {
        let content = ["key": tagkey.text!, "string": tagvalue.text!]
        SHClientsManager.shProcessor?.tagViaLogline(content)
    }

    @IBAction func sendApiTag(_ sender: Any) {
        let content = ["key": tagkey.text!, "string": tagvalue.text!]
        SHClientsManager.shProcessor?.tagViaApi(content, authToken: "1JMyBIGTLLA86MxJ7nCm7kBZoSiOmJ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

