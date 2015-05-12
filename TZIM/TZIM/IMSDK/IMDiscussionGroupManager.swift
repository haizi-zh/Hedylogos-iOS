//
//  IMDiscussionGroupManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMDiscussionGroupManager: NSObject {
    
    /**
    异步创建一个讨论组
    :returns:
    */
    func asyncCreateDiscussionGroup(completion:(isSuccess: Bool, errorCode: Int, discussionGroup: IMDiscussionGroup?)) {
        
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
    
    
    
}
