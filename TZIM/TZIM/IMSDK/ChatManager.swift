
//
//  ChatManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ChatManager: NSObject {
    
    func asyncSendMessage(message: BaseMessage, receiver: String, isChatGroup: Bool, completionBlock: (isSuccess: Bool, errorCode: Int)->()) {
        var daoHelper = DaoHelper()
        daoHelper.updateChatMessageDataWithName("chat_\(receiver)", message: message)
        completionBlock(isSuccess: true, errorCode: 0)
        message.serverId = 888888888
        daoHelper.updateMessageServerId("chat_\(receiver)", localId:1, serverId: message.serverId)
        var operation = NSBlockOperation()
        
        operation.addExecutionBlock { () -> Void in
            var content = message.messageContent
            var contentAfertCrypt = AESCrypt.encrypt(content, password: "password")
            println("加密后:\(contentAfertCrypt)")
            
            var contentDecrypt = AESCrypt.decrypt(contentAfertCrypt, password: "password")
            println("解密后：\(contentDecrypt)")
            NSThread.sleepForTimeInterval(2)
            println(NSThread.currentThread())
            println("执行完毕")
        }
        
        var operation1 = NSBlockOperation()
        operation1.addExecutionBlock { () -> Void in
            var content = message.messageContent
            var contentAfertCrypt = AESCrypt.encrypt(content, password: "password")
            println("加密后:\(contentAfertCrypt)")
            
            var contentDecrypt = AESCrypt.decrypt(contentAfertCrypt, password: "password")
            println("解密后：\(contentDecrypt)")
            println(NSThread.currentThread())
            if !operation.cancelled {
                operation.cancel()
            }
        }
        
    }
}









