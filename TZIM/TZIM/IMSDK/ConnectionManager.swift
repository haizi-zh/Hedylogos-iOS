//
//  ConnectionManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol ConnectionManagerDelegate {
    func connectionSetup(isSuccess: Bool, errorCode: Int);
}

class ConnectionManager: NSObject, PushConnectionDelegate {
    
    let pushSDKManager = PushSDKManager.shareInstance()
    weak var connectionManagerDelegate: ConnectionManagerDelegate?
    
    override init() {
        super.init()
        pushSDKManager.pushConnectionDelegate = self
    }
    
    /**
    登录
    :param: userId   用户名
    :param: password 密码
    */
    func login(userId:Int, password:String) {
        var accountManager = AccountManager.shareInstance()
        accountManager.userId = userId
        pushSDKManager.login(userId, password: password)
    }

    //MARK:PushConnectionDelegate
    func getuiDidConnection(clientId: String) {
        println("GexinSdkDidRegisterClient： \(clientId)")
        var accountManager = AccountManager.shareInstance()
        NetworkUserAPI.asyncLogin(userId: accountManager.userId, registionId: clientId) { (isSuccess: Bool, errorCode: Int) -> () in
            self.connectionManagerDelegate?.connectionSetup(isSuccess, errorCode: 0)
        }
    }
}






