//
//  ConnectionManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject, PushConnectionDelegate {
    
    let pushSDKManager = PushSDKManager.shareInstance()
    
    override init() {
        super.init()
        pushSDKManager.pushConnectionDelegate = self
    }
    
    /**
    登录
    :param: userId   用户名
    :param: password 密码
    */
    func login(userId:String, password:String) {
        pushSDKManager.login(userId, password: password)
    }

    //MARK:PushConnectionDelegate
    
    func getuiDidConnection(clientId: String) {
        println("GexinSdkDidRegisterClient： \(clientId)")
    }
    
}
