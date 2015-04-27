//
//  MessageSendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol MessageSendDelegate {
    
}

private let messageSendManager = MessageSendManager()

class MessageSendManager: MessageTransferManager {
    var messageManagerDelegate: MessageTransferManagerDelegate?
    
    class func shareInstance() -> MessageSendManager {
        return messageSendManager
    }
    
    func asyncSendMessage(message: BaseMessage, receiver: Int, isChatGroup: Bool, completionBlock: (isSuccess: Bool, errorCode: Int)->()) {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(receiver)", message: message)
            daoHelper.closeDB()
        }
        
        for messageManagerDelegate in super.messageTransferManagerDelegateArray {
            (messageManagerDelegate as! MessageTransferManagerDelegate).sendNewMessage?(message)
        }
        var accountManager = AccountManager.shareInstance()
        NetworkTransportAPI.asyncSendMessage(MessageManager.prepareMessage2Send(receiverId: receiver, senderId: accountManager.userId, message: message), completionBlock: { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
            completionBlock(isSuccess: isSuccess, errorCode: errorCode)
            if isSuccess {
                message.status = IMMessageStatus.IMMessageSuccessful
                if let retMessage = retMessage {
                    if let serverId = retMessage.objectForKey("msgId") as? Int {
                        message.serverId = serverId
                    }
                }
            } else {
                message.status = IMMessageStatus.IMMessageFailed
            }
            daoHelper.updateMessageInDB("chat_\(receiver)", message: message)
            for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                (messageManagerDelegate as! MessageTransferManagerDelegate).messageHasSended?(message)
            }
        })
    }
    
    /**
    发送一组消息
    
    :param: messageArray    消息组
    :param: receiver        接受者
    :param: isChatGroup     是否是群聊
    :param: completionBlock 发送后的回掉
    */
    func asyncSendMessageArray(messageArray: NSArray, receiver: Int, isChatGroup: Bool, completionBlock: (isSuccess: Bool, errorCode: Int)->()) {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            for message in messageArray {
                daoHelper.insertChatMessage("chat_\(receiver)", message: (message as! BaseMessage))
            }
            daoHelper.closeDB()
        }
    }
}
