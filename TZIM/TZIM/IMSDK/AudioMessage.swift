//
//  AudioMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class AudioMessage: BaseMessage {
    var audioLength: Float?
    var audioStatus: Int?
    
    override init() {
        super.init()
        messageType = .AudioMessageType
    }
   
}
