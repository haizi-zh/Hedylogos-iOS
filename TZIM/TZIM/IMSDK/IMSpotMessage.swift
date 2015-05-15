//
//  IMSpotMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMSpotMessage: BaseMessage {
    
    var spotId: String!
    var spotName: String?
    var image: String?
    var desc: String?
    var timeCost: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.SpotMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let id = contentsDic.objectForKey("id") as? String {
            spotId = id
        }
        if let name = contentsDic.objectForKey("name") as? String {
            spotName = name
        }
        if let image = contentsDic.objectForKey("image") as? String {
            self.image = image
        }
        if let desc = contentsDic.objectForKey("desc") as? String {
            self.desc = desc
        }
        if let time = contentsDic.objectForKey("timeCost") as? String {
            self.timeCost = time
        }
    }

   
}
