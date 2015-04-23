//
//  ChatManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/22/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ChatManager: NSObject, ChatManagerMessageProtocol, ChatManagerAudioProtocol {
    
    private let chatManagerMessage: ChatManagerMessage!
    private let chatManagerAudio: ChatManagerAudio!
    
    override init() {
        chatManagerMessage = ChatManagerMessage()
        chatManagerAudio = ChatManagerAudio()
    }
    
    func selectChatMessageList(chatterId: Int, untilLocalId localId: Int, messageCount: Int) -> NSArray {
        return chatManagerMessage.selectChatMessageList(chatterId, untilLocalId: localId, messageCount: messageCount)
    }
   
    func beginRecordAudio() {
        chatManagerAudio.beginRecordAudio()
    }
    
    func stopRecordAudio() {
        chatManagerAudio.stopRecordAudio()
    }
    
    func deleteRecordAudio(audioPath: String) {
        chatManagerAudio.deleteRecordAudio(audioPath)
    }
    
    func deleteRecordAudio() {
        chatManagerAudio.deleteRecordAudio()
    }
}
