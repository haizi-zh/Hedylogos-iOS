//
//  NetworkUserAPI.swift
//  TZIM
//
//  Created by liangpengshuai on 4/23/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class NetworkUserAPI: NSObject {
    
    class func asyncLogin(#userId: Int, registionId: String, completionBlock: (isSuccess: Bool, errorCode: Int, retJson: NSDictionary?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        var params = ["userId": userId, "regId": registionId]
        
        println("开始调用登录接口: \(loginUrl)")
        manager.POST(loginUrl, parameters:params, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                    completionBlock(isSuccess: true, errorCode: 200, retJson: nil)
                
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print(error)
                completionBlock(isSuccess: false, errorCode: 400, retJson: nil)
        }
    }
   
}
