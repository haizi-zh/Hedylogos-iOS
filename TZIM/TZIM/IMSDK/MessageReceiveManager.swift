//
//  MessageReceiveManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

enum MessageReceiveDelegateRoutingKey: Int {
    case normal = 1
    case cmd = 2
}

@objc protocol MessageReceiveManagerDelegate {
    /**
    收到新消息
    :param: message 消息内容
    */
    optional func receiveNewMessage(message: BaseMessage)
}

private let messageReceiveManager = MessageReceiveManager()

class MessageReceiveManager: NSObject, PushMessageDelegate, MessageReceivePoolDelegate, MessageManagerDelegate {
    
    private let messageReceiveQueue = dispatch_queue_create("messageReceiveQueue", nil)
    
    /// 收到消息的监听队列，不同的消息有不同的监听者，由 routingkey 区分
    private var receiveDelegateList: Array<[MessageReceiveDelegateRoutingKey: MessageReceiveManagerDelegate]> = Array()
    
    let pushSDKManager = PushSDKManager.shareInstance()
    let messagePool = MessageReceivePool.shareInstance()
    let messageManager = MessageManager.shareInsatance()
    
    private var receiveMessageList: NSDictionary?

    class func shareInstance() -> MessageReceiveManager {
        return messageReceiveManager
    }
    
    override init() {
        super.init()
        pushSDKManager.addPushMessageListener(self, withRoutingKey: "IM")
        messagePool.delegate = self
        messageManager.delegate = self
    }
    
    /**
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addMessageReceiveListener(listener: MessageReceiveManagerDelegate, withRoutingKey routingKey: MessageReceiveDelegateRoutingKey) {
        receiveDelegateList.append([routingKey: listener])
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removeMessageReceiveListener(listener: MessageReceiveManagerDelegate, withRoutingKey routingKey: MessageReceiveDelegateRoutingKey) {
        for (index, value) in enumerate(receiveDelegateList) {
            if value[routingKey] === listener {
                receiveDelegateList.removeAtIndex(index)
                return
            }
        }
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
        
        println("checkMessages queue: \(NSThread.currentThread())")
        
        var allLastMessageList = messageManager.allLastMessageList

        for message in (messageList as! NSMutableArray) {
            if let message = message as? BaseMessage {
                messageManager.addChatMessage2ACK(message)
                
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
            ACKMessageWithReceivedMessages(messagePrepare2Fetch)
        }
        var array = messagePrepate2Distribute as AnyObject as! [BaseMessage]
        distributionMessage(array)
    }
    
    
    /**
    fetch 消息
    
    :param: receivedMessages 已经收到的消息
    */
    func ACKMessageWithReceivedMessages(receivedMessages: NSArray?) {
        var accountManager = IMAccountManager.shareInstance()
        
        println("fetchOmitMessageWithReceivedMessages queue: \(NSThread.currentThread())")
        
        //储存需要额外处理的消息
        var messagesNeed2Deal = NSMutableArray()

        NetworkTransportAPI.asyncACKMessage(accountManager.account.userId, shouldACKMessageList:messageManager.messagesShouldACK, completionBlock: { (isSuccess: Bool, errorCode: Int, retMessage: NSArray?) -> () in
            
            println("fetch Result 一共是：\(retMessage?.count): \(retMessage)")

            if (isSuccess) {
                self.messageManager.clearAllMessageWhenACKSuccess()
                if let retMessageArray = retMessage {
                    dispatch_async(self.messageReceiveQueue, { () -> Void in
                        self.dealwithFetchResult(receivedMessages, fetchMessages: retMessageArray)

                    })
                }
            } else {
                dispatch_async(self.messageReceiveQueue, { () -> Void in
                    self.dealwithFetchResult(receivedMessages, fetchMessages: nil)
                })
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
        
        var allLastMessageList = messageManager.allLastMessageList

        if let receivedMessageArray = receivedMessages {
            messagesPrepare2DistributeArray = receivedMessageArray.mutableCopy() as! NSMutableArray
        } else {
            messagesPrepare2DistributeArray = NSMutableArray()
        }

        if let fetchMessages = fetchMessages {
            for messageDic in fetchMessages {
                if let message = MessageManager.messageModelWithMessage(messageDic) {
                    message.sendType = IMMessageSendType.MessageSendSomeoneElse
                    messageManager.addChatMessage2ACK(message)
                    
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
        var array = messagesPrepare2DistributeArray as AnyObject as! [BaseMessage]
        distributionMessage(array)
    }
    
    /**
    判断一旧消息是否应该被分发出去，如果应该的话将旧消息的时间戳改为当前的时间
    
    :param: message 需要被判断的消息
    :true: 应该
    */
    private func oldMessageShould2Distribution(message: BaseMessage) -> Bool {
        let daoHelper = DaoHelper.shareInstance()
        var chatTableName = "chat_\(message.chatterId)"
        if daoHelper.messageIsExitInTable(chatTableName, message: message) {
            return false
        } else {
            return true
        }
    }
    
    /**
    将合法的消息分发出去
    :param: message
    */
    private func distributionMessage(messageList: Array<BaseMessage>) {

        let daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessageList(messageList, completionBlock: { () -> () in
            for message in messageList {
                
                println("distributionMessage: chatterId: \(message.chatterId)   serverId: \(message.serverId)")
                
                if message.messageType == .ImageMessageType {
                    self.downloadPreviewImageAndDistribution(message as! ImageMessage)
                    
                } else if message.messageType == .AudioMessageType {
                    self.downloadAudioDataAndDistribution(message as! AudioMessage)
                    
                } else  {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if message.messageType == IMMessageType.CMDMessageType {
                            for delegateDic in self.receiveDelegateList {
                                if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.cmd] {
                                    delegate.receiveNewMessage?(message)
                                }
                            }
                        } else {
                            for delegateDic in self.receiveDelegateList {
                                if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.normal] {
                                    delegate.receiveNewMessage?(message)
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    /**
    在通知用户之前先将图片的二进制文件下载下来
    :param: message
    */
    private func downloadPreviewImageAndDistribution(message: ImageMessage) {
        MetadataDownloadManager.asyncDownloadThumbImage(message, completion: { (isSuccess: Bool, retMessage: ImageMessage) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if retMessage.messageType == IMMessageType.CMDMessageType {
                    for delegateDic in self.receiveDelegateList {
                        if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.cmd] {
                            delegate.receiveNewMessage?(retMessage)
                        }
                    }
                } else {
                    for delegateDic in self.receiveDelegateList {
                        if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.normal] {
                            delegate.receiveNewMessage?(retMessage)
                        }
                    }
                }
            })
        })
    }
    
    /**
    在通知用户之前先将图片的二进制文件下载下来
    :param: message
    */
    private func downloadAudioDataAndDistribution(message: AudioMessage) {
        MetadataDownloadManager.asyncDownloadAudioData(message, completion: { (isSuccess: Bool, retMessage: AudioMessage) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if retMessage.messageType == IMMessageType.CMDMessageType {
                    for delegateDic in self.receiveDelegateList {
                        if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.cmd] {
                            delegate.receiveNewMessage?(retMessage)
                        }
                    }
                } else {
                    for delegateDic in self.receiveDelegateList {
                        if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.normal] {
                            delegate.receiveNewMessage?(retMessage)
                        }
                    }
                }
            })
        })
    }
    
//MARK: PushMessageDelegate
    
    func receivePushMessage(message: NSDictionary) {
        NSLog("收到消息： 消息为：\(message)")
        if let message = MessageManager.messageModelWithMessage(message) {
            message.sendType = .MessageSendSomeoneElse
            messagePool.addMessage4Reorder(message)
        }
    }
    
//MARK: MessageReceivePoolDelegate
    
    func messgeReorderOver(messageList: NSDictionary) {
        receiveMessageList = messageList.copy() as? NSDictionary
        dispatch_async(messageReceiveQueue, { () -> Void in
            println("messgeReorderOver queue: \(NSThread.currentThread())")
            for messageList in self.receiveMessageList!.allValues {
                self.checkMessages(messageList as! NSArray)
            }
        })
    }
    
    // MARK: MessageManagerDelegate
    func shouldACK(messageList: Array<String>) {
        self.ACKMessageWithReceivedMessages(nil)
    }
}


























