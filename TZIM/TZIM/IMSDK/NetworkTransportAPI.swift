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

let ACKUrl = "http://hedy.zephyre.me/chats/"

let requestQiniuTokenToUploadMetadata = "http://hedy.zephyre.me/upload/token-generator"


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
    
    /**
    发送一个 post 请求
    
    :param: url             请求的 url
    :param: parameters      post 参数
    :param: completionBlock 请求的回掉
    */
    class func asyncPOST(#requstUrl: String, parameters: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer
        var accountManager = IMAccountManager.shareInstance()
        manager.requestSerializer.setValue("\(accountManager.account.userId)", forHTTPHeaderField: "UserId")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        manager.POST(requstUrl, parameters: parameters, success:
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
    发送一个 post 请求
    
    :param: url             请求的 url
    :param: parameters      post 参数
    :param: completionBlock 请求的回掉
    */
    class func asyncGET(#requestUrl: String, parameters: NSDictionary?, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: AnyObject?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer
        var accountManager = IMAccountManager.shareInstance()
        manager.requestSerializer.setValue("\(accountManager.account.userId)", forHTTPHeaderField: "UserId")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        println("开始网络请求: \(requestUrl)")
        
        manager.GET(requestUrl, parameters: parameters, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if let reslutDic: AnyObject = responseObject.objectForKey("result") {
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
    class func asyncACKMessage(userId: Int, shouldACKMessageList: Array<String>, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSArray?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        println("开始执行 ACK 接口")
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        var params = ["msgList": shouldACKMessageList]
        
        println("ACK接口,收取用户\(userId) 的未读消息")
        
        var url = ACKUrl+"\(userId)"+"/ack"
        
        manager.POST(url, parameters: params, success:
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







