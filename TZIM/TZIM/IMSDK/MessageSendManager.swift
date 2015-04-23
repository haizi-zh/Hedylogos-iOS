//
//  MessageSendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol MessageSendDelegate {
    
    /**
    发送消息
    
    :param: message         消息内容
    :param: receiver        接受者
    :param: isChatGroup     是否是群聊天
    :param: completionBlock 发送的回掉
    */
    func asyncSendMessage(message: BaseMessage, receiver: Int, isChatGroup: Bool, completionBlock: (isSuccess: Bool, errorCode: Int)->())
    
}

class MessageSendManager: MessageTransferManager {
    var messageManagerDelegate: MessageTransferManagerDelegate?
    
    //MARK: MessageSendDelegate
    func asyncSendMessage(message: BaseMessage, receiver: Int, isChatGroup: Bool, completionBlock: (isSuccess: Bool, errorCode: Int)->()) {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(receiver)", message: message)
            daoHelper.closeDB()
        }
        NetworkTransportAPI.asyncSendMessage(message.prepareMessage2Send(String(receiver)), completionBlock: { (isSuccess, errorCode) -> () in
            completionBlock(isSuccess: isSuccess, errorCode: errorCode)
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
//        var networkManager = NetworkTransportManager()
//        networkManager.asyncSendMessage(message.prepareMessage2Send(String(receiver)), completionBlock: { (isSuccess, errorCode) -> () in
//            completionBlock(isSuccess: isSuccess, errorCode: errorCode)
//        })
    }
}
