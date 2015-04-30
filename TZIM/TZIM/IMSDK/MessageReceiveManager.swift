//
//  MessageReceiveManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let messageReceiveManager = MessageReceiveManager()

class MessageReceiveManager: MessageTransferManager, PushMessageDelegate, MessageReceivePoolDelegate {
    let pushSDKManager = PushSDKManager.shareInstance()
    let messagePool = MessageReceivePool.shareInstance()

    class func shareInstance() -> MessageReceiveManager {
        return messageReceiveManager
    }
    
    override init() {
        super.init()
        pushSDKManager.pushMessageDelegate = self
        messagePool.delegate = self
    }
    
//MARK: private method
    
    /**
    检查属于一组消息是否合法
    :param: messageList 待检查的消息
    */
    private func checkMessages(messageList: NSArray) {

        var messagePrepate2Distribute = NSMutableArray()
        var messagePrepare2Fetch = NSMutableArray()
        var needFetchMessage = false
        
        var allLastMessageList = MessageManager.shareInsatance().allLastMessageList

        for message in (messageList as! NSMutableArray) {
            if let message = message as? BaseMessage {
                if let lastMessageServerId: AnyObject = allLastMessageList.objectForKey(message.chatterId) {
                    if (message.serverId - (lastMessageServerId as! Int)) > 1 {
                        println("消息非法: 带插入的 serverId: \(message.serverId)  最后一条的 serverId: \(lastMessageServerId)")
                        var index = messageList.indexOfObject(message)
                        for var i = index; i < messageList.count; i++ {
                            messagePrepare2Fetch.addObject(messageList.objectAtIndex(i))
                        }

                        needFetchMessage = true
                        break
                        
                    } else if (message.serverId - (lastMessageServerId as! Int)) == 1 {
                        allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                        println("消息合法: 带插入的 serverId: \(message.serverId)  最后一条的 serverId: \(lastMessageServerId)")
                        messagePrepate2Distribute.addObject(message)
                        
                    } else {
                        if oldMessageShould2Distribution(message) {
                            messagePrepate2Distribute.addObject(message)
                        }
                    }
                    
                } else {
                    println("这是一条数据库不存在的消息: 带插入的 serverId: \(message.serverId))")
                    allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                    messagePrepate2Distribute.addObject(message)
                }
            }
        }

        println("进行插入的消息一共有\(messagePrepate2Distribute.count) 条")
        
        if needFetchMessage {
            println("存在不合法的消息, 需要 fetch")
            fetchOmitMessageWithReceivedMessages(messagePrepare2Fetch)
        }
        
        for message in messagePrepate2Distribute {
            println("合法的消息的 message id 为\((message as? BaseMessage)?.serverId)")
            distributionMessage(message as? BaseMessage)
        }
    }
    
    
    /**
    fetch 遗漏的消息
    
    :param: receivedMessages 已经收到的消息
    */
    func fetchOmitMessageWithReceivedMessages(receivedMessages: NSArray) {
        var accountManager = AccountManager.shareInstance()
        
        //储存需要额外处理的消息
        var messagesNeed2Deal = NSMutableArray()

        NetworkTransportAPI.asyncFecthMessage(accountManager.userId, completionBlock: { (isSuccess: Bool, errorCode: Int, retMessage: NSArray?) -> () in
            if (isSuccess) {
                if let retMessageArray = retMessage {
                    self.dealwithFetchResult(receivedMessages, fetchMessages: retMessageArray)
                }
            } else {
                self.dealwithFetchResult(receivedMessages, fetchMessages: nil)
            }
        })
    }
    
    /**
    处理 fetch 后的数据,当判断不合理的消息不再 fetch
    :param: receivedMessages
    :param: fetchMessages
    */
    private func dealwithFetchResult(receivedMessages: NSArray?, fetchMessages: NSArray?) {
        var messagesPrepare2DistributeArray = NSMutableArray()
        
        var allLastMessageList = MessageManager.shareInsatance().allLastMessageList

        if let receivedMessageArray = receivedMessages {
            messagesPrepare2DistributeArray = receivedMessageArray.mutableCopy() as! NSMutableArray
        } else {
            messagesPrepare2DistributeArray = NSMutableArray()
        }

        if let fetchMessages = fetchMessages {
            for messageDic in fetchMessages {
                if let message = MessageManager.messageModelWithMessage(messageDic) {
                    message.sendType = IMMessageSendType.MessageSendSomeoneElse
                    
                    if let lastMessageServerId: AnyObject = allLastMessageList.objectForKey(message.chatterId) {
                        if (message.serverId - (lastMessageServerId as! Int)) >= 1 {
                            allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                            println("消息合法: 带插入的 serverId: \(message.serverId)  最后一条的 serverId: \(lastMessageServerId)")
                            
                            var haveAdded = false
                            for var i = messagesPrepare2DistributeArray.count-1; i>=0; i-- {
                                var oldMessage = messagesPrepare2DistributeArray.objectAtIndex(i) as! BaseMessage
                                if (message.serverId == oldMessage.serverId && message.chatterId == oldMessage.chatterId) {
                                    haveAdded = true
                                    println("equail....")
                                    break
                                    
                                } else if (message.serverId < oldMessage.serverId && message.chatterId == oldMessage.chatterId) {
                                    println("continue....message ServerID:\(message.serverId)  oldMessage.serverId: \(oldMessage.serverId)")
                                    continue
                                    
                                } else if (message.serverId > oldMessage.serverId && message.chatterId == oldMessage.chatterId) {
                                    messagesPrepare2DistributeArray.insertObject(message, atIndex: i+1)
                                    println("> and insert atIndex \(i+1)")
                                    haveAdded = true
                                    break
                                }
                            }
                            if !haveAdded {
                                messagesPrepare2DistributeArray.insertObject(message, atIndex: 0)
                                println("not find and insert atIndex \(0)")
                            }
                            
                            
                        } else {
                            if oldMessageShould2Distribution(message) {
                                messagesPrepare2DistributeArray.addObject(message)
                            }
                        }
                        
                    } else {
                        messagesPrepare2DistributeArray.addObject(message)
                        allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                    }
                }
            }
        }
        println("共有\(messagesPrepare2DistributeArray.count)条消息是从 fetch 接口过来的，并且是合法的")
        for message in messagesPrepare2DistributeArray {
            println("fetch后 合法的消息的 message id 为\((message as? BaseMessage)?.serverId)")
            distributionMessage(message as? BaseMessage)
        }
    }
    
    /**
    判断一旧消息是否应该被分发出去，如果应该的话将旧消息的时间戳改为当前的时间
    
    :param: message 需要被判断的消息
    :true: 应该
    */
    private func oldMessageShould2Distribution(message: BaseMessage) -> Bool {
        let daoHelper = DaoHelper()
        if daoHelper.openDB() {
            var chatTableName = "chat_\(message.chatterId)"
            if daoHelper.messageIsExitInTable(chatTableName, message: message) {
                daoHelper.closeDB()
                return false
            } else {
                daoHelper.closeDB()
                return true
            }

        }
        return false
    }
    
    /**
    将合法的消息分发出去
    :param: message
    */
    private func distributionMessage(message: BaseMessage?) {
        println("distributionMessage: chatterId: \(message?.chatterId)   serverId: \(message?.serverId)")
        if let message = message {
            let daoHelper = DaoHelper()
            if daoHelper.openDB() {
                var tableName = "chat_\(message.chatterId)"
                daoHelper.insertChatMessage(tableName, message: message)
                daoHelper.closeDB()
            }
            switch message {
            case let textMsg as TextMessage:
                for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                    (messageManagerDelegate as! MessageTransferManagerDelegate).receiveNewMessage?(message)
                }
                
            default:
                break
            }
        }
    }
    
    
    
//MARK: PushMessageDelegate
    
    func receivePushMessage(message: NSString) {
        if let message = MessageManager.messageModelWithMessage(message) {
            message.sendType = .MessageSendSomeoneElse
            messagePool.addMessage4Reorder(message)
        }
    }
    


//MARK: MessageReceivePoolDelegate
    
    func messgeReorderOver(messageList: NSDictionary) {
        for messageList in messageList.allValues {
           checkMessages(messageList as! NSArray)
        }

    }
}























