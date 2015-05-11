//
//  IMGroupManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let groupUrl = "http://hedy.zephyre.me/groups"


class IMGroupManager: NSObject {
    
    func loadAllMyGroupsFromServer() -> NSArray {
        
    }
    
    func loadAllMyGroupsFromDB() -> NSArray {
        return NSArray()
    }
    
    func asyncCreateGroup(#subject: NSString, description: String?, isPublic: Bool, invitees: Array<Int>, welcomeMessage: String?, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        var params = NSMutableDictionary()
        params.setObject(subject, forKey: "name")
        params.setObject(isPublic, forKey: "isPublic")
        params.setObject(invitees, forKey: "participants")
        NetworkTransportAPI.asyncPOST(requstUrl: groupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            completionBlock(isSuccess: isSuccess, errorCode: errorCode, retMessage: retMessage)
        }
    }
    
    func asyncRequestJoinGroup(#groupId: Int, request: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncLeaveGroup(#groupId: Int, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncDestroyGroup(#groupId: Int, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncAddNumbers2Group(#groupId: Int, numbers: Array<Int>, welcomeMessage: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncRemoveNumbersFromGroup(#groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncBlockNumbers(#groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }

    func asyncUnBlockNumbers(#groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncChangeGroupSubject(#groupId: Int, subject: String, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncChangeGroupDescription(#groupId: Int, description: String, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    


}
