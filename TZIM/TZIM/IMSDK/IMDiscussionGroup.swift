//
//  IMDiscussionGroup.swift
//  TZIM
//
//  Created by liangpengshuai on 5/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMDiscussionGroup: NSObject {
    
    var groupId: Int!
    var subject: String!
    
    init(jsonData: NSDictionary) {
        groupId = jsonData.objectForKey("groupId") as! Int
        subject = jsonData.objectForKey("name") as! String
    }

}
