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
    var creator: FrendModel!
   
}
