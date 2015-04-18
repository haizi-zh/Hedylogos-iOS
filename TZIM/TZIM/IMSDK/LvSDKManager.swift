//
//  LvSDKManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let iMClientManager = IMClientManager()

class IMClientManager: NSObject {
    let connectionManager: ConnectionManager
    let messageManager: MessageManager
    let pushSDKManager: PushSDKManager
    
    override init() {
        connectionManager = ConnectionManager()
        messageManager = MessageManager()
        pushSDKManager = PushSDKManager()
        super.init()
    }
    
    deinit {
        println("IMClientManager deinit")
    }
    
    class var shareInstance : IMClientManager {
        return iMClientManager
    }
}
