//
//  LocationMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class LocationMessage: BaseMessage {
    var longitude: Double = 0
    var latitude: Double = 0
    var address: String = ""
    
    override init() {
        super.init()
        messageType = .TextMessageType
    }
}
