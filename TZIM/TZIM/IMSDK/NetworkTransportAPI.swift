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

protocol NetworkTransportProtocol {
    
    /**
    向服务器发送一条消息
    
    :param: message         消息的格式
    :param: completionBlock 完成后的回掉
    */
    static func asyncSendMessage(message: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int) -> ())
}

class NetworkTransportAPI: NSObject, NetworkTransportProtocol {
    
    class func asyncSendMessage(message: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer

        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        println("发送消息接口\(message)")
        manager.POST(sendMessageURL, parameters: message, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                completionBlock(isSuccess: true, errorCode: 200)
                
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print(error)
                completionBlock(isSuccess: false, errorCode: 400)
        }
    }
}
