//
//  MessageReceivePool.swift
//  TZIM
//
//  Created by liangpengshuai on 4/29/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let messageReceivePool = MessageReceivePool()
private let reorderTime = 0.5

@objc protocol MessageReceivePoolDelegate {
    /**
    消息重组已经完成
    :param: messageList 重组后的消息列表
    */
    func messgeReorderOver(messageList:  NSDictionary)
}

class MessageReceivePool: NSObject {
    
    private let messagePrepare2Reorder: NSMutableDictionary = NSMutableDictionary()
    private var timer: NSTimer?
    
    weak var delegate: MessageReceivePoolDelegate?
    
    class func shareInstance() -> MessageReceivePool {
        return messageReceivePool
    }
    
    deinit {
        println("MessageReceivePool deinit")
    }
    
    private func startTimer() {
        println("启动定时器")
        timer = NSTimer.scheduledTimerWithTimeInterval(reorderTime, target: self, selector: Selector("distrubuteMessage"), userInfo: nil, repeats: false)
    }
    
    /**
    添加收到的信息准备排序
    :param: message
    */
    func addMessage4Reorder(message: BaseMessage) {
        if timer == nil {
            startTimer()
        }
        if conversationIsExit(message) {
            var messageList = messagePrepare2Reorder.objectForKey(message.chatterId) as! NSMutableArray
            var haveAdded = false
            for var i = messageList.count-1; i>=0; i-- {
                var oldMessage = messageList.objectAtIndex(i) as! BaseMessage
                if message.serverId == oldMessage.serverId {
                    haveAdded = true
                    println("equail....")
                    break
                    
                } else if message.serverId < oldMessage.serverId {
                    println("continue....message ServerID:\(message.serverId)  oldMessage.serverId: \(oldMessage.serverId)")
                    continue
                    
                } else if message.serverId > oldMessage.serverId {
                    messageList.insertObject(message, atIndex: i+1)
                    println("> and insert atIndex \(i+1)")
                    haveAdded = true
                    break
                }
            }
            if !haveAdded {
                messageList.insertObject(message, atIndex: 0)
                println("not find and insert atIndex \(0)")
            }
            
        } else {
            var newMessageList = NSMutableArray()
            newMessageList.addObject(message)
            println("newMessageList")
            messagePrepare2Reorder.setObject(newMessageList, forKey: message.chatterId)
        }
    }
    
    /**
    判断收到的消息是否已经有对应的会话存在
    :param: message
    :returns:
    */
    private func conversationIsExit(message: BaseMessage) -> Bool {
        for key in messagePrepare2Reorder.allKeys {
            if (key as! Int) == message.chatterId {
                return true
            }
        }
        return false
    }
    
    func distrubuteMessage() {
        var count = 0
        for messageList in messagePrepare2Reorder.allValues {
            count++
            println("*************第 \(count)组消息***********")
            for message in (messageList as! NSMutableArray) {
                println("messageId: \((message as! BaseMessage).serverId)")
            }
            println("*************第 \(count)组消息 OVER***********")
        }
        println("消息已经重组完成")
        
        delegate?.messgeReorderOver(messagePrepare2Reorder)
        messagePrepare2Reorder.removeAllObjects()
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}



