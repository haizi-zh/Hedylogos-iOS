//
//  LvSDKManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let iMClientManager = IMClientManager()

@objc protocol IMClientDelegate {
    
    func userDidLogin(isSuccess: Bool, errorCode: Int)
    
}

class IMClientManager: NSObject, ConnectionManagerDelegate {
    
    var connectionManager: ConnectionManager
    var messageReceiveManager: MessageReceiveManager!
    var messageSendManager: MessageSendManager!
    var conversationManager: ChatConversationManager!
    
    weak var delegate: IMClientDelegate?
    
    override init() {
        connectionManager = ConnectionManager()
        super.init()
        connectionManager.connectionManagerDelegate = self
    }
    
    deinit {
        println("IMClientManager deinit")
    }
    
    class func shareInstance() -> IMClientManager {
        return iMClientManager
    }
    
    
//MARK: ConnectionManager
    func connectionSetup(isSuccess: Bool, errorCode: Int) {
        if isSuccess {
            self.messageReceiveManager = MessageReceiveManager.shareInstance()
            self.messageSendManager = MessageSendManager.shareInstance()
            self.conversationManager = ChatConversationManager()
            self.messageSendManager.addMessageSendDelegate(conversationManager)
            let cmdMessageManager = CMDMessageManager.shareInstance()
            self.messageReceiveManager.addMessageReceiveListener(cmdMessageManager, withRoutingKey: MessageReceiveDelegateRoutingKey.cmd)
            self.messageReceiveManager.addMessageReceiveListener(conversationManager, withRoutingKey: MessageReceiveDelegateRoutingKey.normal)
            self.messageReceiveManager.ACKMessageWithReceivedMessages(nil)
        }
        delegate?.userDidLogin(isSuccess, errorCode: errorCode)
    }


}
