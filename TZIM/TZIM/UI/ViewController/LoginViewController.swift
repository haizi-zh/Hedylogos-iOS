//
//  LoginViewController.swift
//  TZIM
//
//  Created by liangpengshuai on 4/23/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, ConnectionManagerDelegate {

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func login(sender: AnyObject) {
        var manager = IMClientManager.shareInstance
        
        if let userId = userIdTextField.text.toInt() {
            manager.connectionManager.login(userId, password: "")
            manager.connectionManager.connectionManagerDelegate = self
            SVProgressHUD.show()
            self.view.endEditing(true)
        }
    }
    
    //MARK: ConnectionManagerDelegate
    func userDidLogin() {
        SVProgressHUD.dismiss()
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var conversationCtl = storyBoard.instantiateViewControllerWithIdentifier("conversationCtl") as! ConversationViewController
        self.navigationController?.viewControllers[0] = conversationCtl
    }
}

