//
//  NetworkTransportManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/20/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let loginUrl = "http://hedy.zephyre.me/users/login"

let sendMessageURL = "http://hedy.zephyre.me/chats"

let fetchUrl = "http://hedy.zephyre.me/chats/"


class NetworkTransportAPI: NSObject {
    
    /**
    向服务器发送一条消息
    
    :param: message         消息的格式
    :param: completionBlock 完成后的回掉
    */
    class func asyncSendMessage(message: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer

        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        println("发送消息接口\(message)")
        manager.POST(sendMessageURL, parameters: message, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if let reslutDic = responseObject.objectForKey("result") as? NSDictionary {
                    completionBlock(isSuccess: true, errorCode: 0, retMessage: reslutDic)
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print(error)
                completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
        }
    }
    
   
    /**
    fetch 消息
    
    :param: userId          fetch谁的消息
    :param: completionBlock fetch 后的回掉
    */
    class func asyncFecthMessage(userId: Int, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSArray?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        println("开始执行 fetch 接口")
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        var params = ["userId": userId]
        
        println("fetch接口,收取用户\(userId) 的未读消息")
        
        var url = fetchUrl+"\(userId)"
        
        manager.GET(url, parameters: params, success:
        {
        (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            if let reslutDic = responseObject.objectForKey("result") as? NSArray {
                completionBlock(isSuccess: true, errorCode: 0, retMessage: reslutDic)
                
            } else {
                completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)

            }
        })
        {
        (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        print(error)
            completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
        }
    }
}

let testArray = ["{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(18),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello\(NSDate())\",\"senderId\":\(9),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}",
    
     "{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(19),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello\(NSDate())\",\"senderId\":\(9),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}",
    
    "{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(11),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello\(NSDate())\",\"senderId\":\(10),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}",

]







