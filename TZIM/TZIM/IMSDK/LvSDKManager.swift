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
    let messageReceiveManager: MessageReceiveManager
    let messageSendManager: MessageSendManager
    let conversationManager: ChatConversationManager
    let pushSDKManager: PushSDKManager
    let frendManager: FrendManager
    
    override init() {
        connectionManager = ConnectionManager()
        messageReceiveManager = MessageReceiveManager()
        messageSendManager = MessageSendManager()
        pushSDKManager = PushSDKManager()
        conversationManager = ChatConversationManager()
        frendManager = FrendManager()
        super.init()
        self.addMessageDelegate(conversationManager)
    }
    
    deinit {
        println("IMClientManager deinit")
    }
    
    class var shareInstance : IMClientManager {
        return iMClientManager
    }
    
    func addMessageDelegate(messageDelegate: MessageTransferManagerDelegate) {
        messageReceiveManager.addMessageDelegate(messageDelegate)
        messageSendManager.addMessageDelegate(messageDelegate)
    }
}
