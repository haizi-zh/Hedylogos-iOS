//
//  MessageReceiveManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class MessageReceiveManager: NSObject, PushMessageDelegate {
    let pushSDKManager = PushSDKManager.shareInstance()
    var messageManagerDeleagteArray: NSArray!
    
    override init() {
        super.init()
        pushSDKManager.pushMessageDelegate = self
    }
    
    func receiveGetuiMessage(message: NSString) {
        println("receiveGetuiMessage：\(message)")
        var message = BaseMessage()
        for messageManagerDelegate in messageManagerDeleagteArray {
            (messageManagerDelegate as! MessageManagerDelegate).receiveNewMessage(message, fromUser: "")
        }
    }
}
