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
}
