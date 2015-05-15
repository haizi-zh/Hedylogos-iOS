//
//  IMGuideMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMGuideMessage: BaseMessage {
    
    var guideId: String!
    var guideName: String?
    var image: String?
    var desc: String?
    var timeCost: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.GuideMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let id = contentsDic.objectForKey("id") as? String {
            guideId = id
        }
        if let name = contentsDic.objectForKey("name") as? String {
            guideName = name
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
