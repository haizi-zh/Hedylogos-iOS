//
//  LoginViewController.swift
//  TZIM
//
//  Created by liangpengshuai on 4/23/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, IMClientDelegate {

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        var accountManager = IMAccountManager.shareInstance()
        if accountManager.account != nil {
            userIdTextField.text = "\(accountManager.account.userId)"
//            self.login(0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func login(sender: AnyObject) {
        var manager = IMClientManager.shareInstance()
        
        if let userId = userIdTextField.text.toInt() {
            manager.connectionManager.login(userId, password: "")
            manager.delegate = self
            SVProgressHUD.show()
            self.view.endEditing(true)
        }
    }
    
    //MARK: ConnectionManagerDelegate
    func userDidLogin(isSuccess: Bool, errorCode: Int) {
        
        SVProgressHUD.dismiss()
        
        if isSuccess {
            var storyBoard = UIStoryboard(name: "Main", bundle: nil)
            var conversationCtl = storyBoard.instantiateViewControllerWithIdentifier("homeCtl") as! HomeViewController
            self.navigationController?.viewControllers[0] = conversationCtl
        } else {
            SVProgressHUD.showErrorWithStatus("登录失败: code :\(errorCode)")
        }
    }
}

