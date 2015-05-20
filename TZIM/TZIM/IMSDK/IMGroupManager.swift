//
//  IMGroupManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let groupUrl = "http://hedy.zephyre.me/groups"

let groupManager = IMGroupManager()

class IMGroupManager: NSObject {
    private var delegateQueue: Array<IMGroupManager> = Array()
    
//MARK: public function
    
    class func shareInstance() -> IMGroupManager {
        return groupManager
    }
    
    /**
    添加一个讨论组的 delegate
    
    :param: delegate
    */
    func addDelegate(delegate: IMGroupManager) {
        delegateQueue.append(delegate)
    }
    
    /**
    删除一个讨论组的 delegate
    
    :param: delegate
    */
    func removeDelegate(delegate: IMGroupManager) {
        for (index, value) in enumerate(delegateQueue) {
            if value === delegate {
                delegateQueue.removeAtIndex(index)
                return
            }
        }
    }
    
    func asyncLoadAllMyGroupsFromServer(completionBlock: (isSuccess: Bool, errorCode: Int, groupList: Array<IMGroupModel>) -> ()) {
        let groupListUrl = "\(userUrl)/\(IMAccountManager.shareInstance().account.userId)/groups"
        NetworkTransportAPI.asyncGET(requestUrl: groupListUrl, parameters: nil) { (isSuccess, errorCode, retMessage) -> () in
            var groupList = Array<IMGroupModel>()
            if let retData = retMessage as? NSArray {
                for groupData in retData  {
                    var group = IMGroupModel(jsonData: groupData as! NSDictionary)
                    groupList.append(group)
                    var frendManager = FrendManager()
                    frendManager.addFrend2DB(self.convertGroupModel2FrendModel(group))
                }
            }
            completionBlock(isSuccess: isSuccess, errorCode: errorCode, groupList: groupList)
        }
    }
    
    func loadAllMyGroupsFromDB() -> Array<IMGroupModel> {
        var daoHelper = DaoHelper()
        return daoHelper.selectAllGroup()
    }
    
    func asyncCreateGroup(#subject: NSString, description: String?, isPublic: Bool, invitees: Array<Int>, welcomeMessage: String?, completionBlock: (isSuccess: Bool, errorCode: Int, retGroup: IMGroupModel?) -> ()) {
        var params = NSMutableDictionary()
        params.setObject(subject, forKey: "name")
        params.setObject(isPublic, forKey: "isPublic")
        params.setObject("common", forKey: "groupType")
        params.setObject(invitees, forKey: "participants")

        NetworkTransportAPI.asyncPOST(requstUrl: groupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                var group = IMGroupModel(jsonData: retMessage!)
                var frendManager = FrendManager()
                frendManager.addFrend2DB(self.convertGroupModel2FrendModel(group))
                completionBlock(isSuccess: isSuccess, errorCode: errorCode, retGroup: group)
            } else {
                completionBlock(isSuccess: isSuccess, errorCode: errorCode, retGroup: nil)
            }
        }
    }
    
    func asyncRequestJoinGroup(#groupId: Int, request: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject("join", forKey: "action")
        params.setObject("\(request)", forKey: "message")
        var requestAddGroupUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: requestAddGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
        
    }
    
    func asyncLeaveGroup(#groupId: Int, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject("exit", forKey: "action")
        var exitGroupUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: exitGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    func asyncDestroyGroup(#groupId: Int, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncAddNumbers2Group(#groupId: Int, numbers: Array<Int>, welcomeMessage: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject("addMembers", forKey: "action")
        params.setObject(groupId, forKey: "id")
        params.setObject(numbers, forKey: "participants")
        let addNumberUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    func asyncRemoveNumbersFromGroup(#groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject("delMembers", forKey: "action")
        params.setObject(groupId, forKey: "id")
        params.setObject(numbers, forKey: "participants")
        let addNumberUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    func asyncBlockNumbers(#groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject("silence", forKey: "action")
        params.setObject(groupId, forKey: "id")
        params.setObject(numbers, forKey: "participants")
        let addNumberUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }

    func asyncUnBlockNumbers(#groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncChangeGroupSubject(#groupId: Int, subject: String, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncChangeGroupDescription(#groupId: Int, description: String, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    
//MARK: private function
    /**
    将一个群组转换成一个frendmodel
    
    :param: group
    
    :returns:
    */
    func convertGroupModel2FrendModel(group: IMGroupModel) -> FrendModel {
        var frendModel = FrendModel()
        frendModel.userId = group.groupId
        frendModel.nickName = group.subject
        frendModel.type = IMFrendType.Group
        return frendModel
    }


}
