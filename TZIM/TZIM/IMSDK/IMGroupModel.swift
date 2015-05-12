//
//  IMGroupModel.swift
//  TZIM
//
//  Created by liangpengshuai on 5/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMGroupModel: NSObject {
    
    var groupId: Int!
    var subject: String!
    var desc: String?
    var isPublic: Bool = false
    var maxUser: Int = 0
    var tags: Array<String>?
    var creatorId: Int!
    var conversationId: String = String()
    
    init(jsonData: NSDictionary) {
        groupId = jsonData.objectForKey("groupId") as! Int
        subject = jsonData.objectForKey("name") as! String
        desc = jsonData.objectForKey("desc") as? String
        creatorId = jsonData.objectForKey("creator") as? Int
        if let conversationId = jsonData.objectForKey("conversation") as? String {
            self.conversationId = conversationId
        }
        super.init()
    }
    
    override init() {
        super.init()
    }
}



