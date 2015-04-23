//
//  MessageReceiveManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class MessageReceiveManager: MessageTransferManager, PushMessageDelegate {
    let pushSDKManager = PushSDKManager.shareInstance()
    
    override init() {
        super.init()
        pushSDKManager.pushMessageDelegate = self
    }
    
    //MARK: PushMessageDelegate
    func receiveGetuiMessage(message: NSString) {
        
        var message = BaseMessage()
        for messageManagerDelegate in super.messageTransferManagerDelegateArray {
            (messageManagerDelegate as! MessageTransferManagerDelegate).receiveNewMessage(message, fromUser: "")
        }
    }
}
