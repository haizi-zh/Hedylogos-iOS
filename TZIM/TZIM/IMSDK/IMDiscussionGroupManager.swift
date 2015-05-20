//
//  IMDiscussionGroupManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol DiscusssionGroupManagerDelegate {
    
}

let discussionGroupManager = IMDiscussionGroupManager()

class IMDiscussionGroupManager: NSObject {
    
    private var delegateQueue: Array<DiscusssionGroupManagerDelegate> = Array()
    
    class func shareInstance() -> IMDiscussionGroupManager {
        return discussionGroupManager
    }
    
    /**
    添加一个讨论组的 delegate
    
    :param: delegate
    */
    func addDelegate(delegate: DiscusssionGroupManagerDelegate) {
        delegateQueue.append(delegate)
    }
    
    /**
    删除一个讨论组的 delegate
    
    :param: delegate
    */
    func removeDelegate(delegate: DiscusssionGroupManagerDelegate) {
        for (index, value) in enumerate(delegateQueue) {
            if value === delegate {
                delegateQueue.removeAtIndex(index)
                return
            }
        }
    }
    
    /**
    异步创建一个讨论组
    :returns:
    */
    func asyncCreateDiscussionGroup(invitees: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int, discussionGroup: IMDiscussionGroup?) -> ()) {
        var params = NSMutableDictionary()
        params.setObject(invitees, forKey: "participants")
        
        NetworkTransportAPI.asyncPOST(requstUrl: groupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                var group = IMDiscussionGroup(jsonData: retMessage!)
                var frendManager = FrendManager()
                frendManager.addFrend2DB(self.convertDiscussionGroupModel2FrendModel(group))
                completionBlock(isSuccess: true, errorCode: errorCode, discussionGroup: group)
            } else {
                completionBlock(isSuccess: isSuccess, errorCode: errorCode, discussionGroup: nil)
            }
        }
    }
    
    /**
    获取我所有的讨论组
    
    :param: completionBlock 
    */
    func asyncLoadAllMyDiscussionGroupsFromServer(completionBlock: (isSuccess: Bool, errorCode: Int, groupList: Array<IMDiscussionGroup>) -> ()) {
        let groupListUrl = "\(userUrl)/\(IMAccountManager.shareInstance().account.userId)/groups"
        NetworkTransportAPI.asyncGET(requestUrl: groupListUrl, parameters: nil) { (isSuccess, errorCode, retMessage) -> () in
            var groupList = Array<IMDiscussionGroup>()
            if let retData = retMessage as? NSArray {
                for groupData in retData  {
                    var group = IMDiscussionGroup(jsonData: groupData as! NSDictionary)
                    groupList.append(group)
                    var frendManager = FrendManager()
                    frendManager.addFrend2DB(self.convertDiscussionGroupModel2FrendModel(group))
                }
            }
            completionBlock(isSuccess: isSuccess, errorCode: errorCode, groupList: groupList)
        }
    }
    
    /**
    申请加入讨论组
    
    :param: groupId
    :param: request
    :param: completionBlock     
    */
    func asyncRequestJoinDiscussionGroup(#groupId: Int, request: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject("join", forKey: "action")
        params.setObject("\(request)", forKey: "message")
        var requestAddGroupUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: requestAddGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    /**
    离开一个讨论组
    
    :param: completion
    */
    func asyncLeaveDiscussionGroup(completion:(isSuccess: Bool, errorCode: Int)) {
    }
    
    func asyncChangeDiscussionGroupTitle(completion:(isSuccess: Bool, errorCode: Int)) {
    }
    
    func asyncAddNumbers(numbers: Array<FrendModel>, completion:(isSuccess: Bool, errorCode: Int)) {
    }

    
 //MARK: private function
    /**
    将一个群组转换成一个frendmodel
    
    :param: group
    
    :returns:
    */
    func convertDiscussionGroupModel2FrendModel(group: IMDiscussionGroup) -> FrendModel {
        var frendModel = FrendModel()
        frendModel.userId = group.groupId
        frendModel.nickName = group.subject
        frendModel.type = IMFrendType.DiscussionGroup
        return frendModel
    }

    
}
