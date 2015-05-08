//
//  ChatManagerAudio.swift
//  TZIM
//
//  Created by liangpengshuai on 4/22/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol ChatManagerAudioProtocol {
    /**
    开始录音
    */
    func beginRecordAudio()
    /**
    结束录音
    */
    func stopRecordAudio()
    
    /**
    删除录音文件
    */
    func deleteRecordAudio()
    
    /**
    删除指定录音文件
    :param: audioPath
    */
    func deleteRecordAudio(audioPath: String)

}

@objc protocol ChatManagerAudioDelegate {
    
    func audioRecordEnd(audioPath: String)

}

class ChatManagerAudio: NSObject, ChatManagerAudioProtocol, AudioManagerDelegate {
    
    private var audioRecordDeviceManager: AudioRecordDeviceManager!
    private var audioPath : String = ""
    private let chatterId: Int
    private let chatType: IMChatType
    
    weak var delegate: ChatManagerAudioDelegate?
    
    var timer: NSTimer!
    
    var timeCounter: Float = 0

    init(tChatterId: Int, tChatType: IMChatType) {
        audioRecordDeviceManager = AudioRecordDeviceManager.shareInstance()
        chatType = tChatType
        chatterId = tChatterId
        super.init()
    }
    
    //MARK: private methods
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateMeters"), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if (timer != nil && timer.valid) {
            timer.invalidate()
            timer = nil
        }
    }

    func updateMeters() {
        timeCounter += 0.1
        var averagePower = audioRecordDeviceManager.updateMeters()
        println("正在录音，已经录制：\(timeCounter) 声音分贝为：\(averagePower)")
    }
    
    //MARK: ChatManagerAudioProtocol
    func beginRecordAudio() {
        audioRecordDeviceManager.audioManagerDelegate = self
        audioPath = documentPath.stringByAppendingPathComponent("test.wav")
        var audioUrl = NSURL(string: audioPath)
        audioRecordDeviceManager.beginRecordAudio(audioUrl!)
        startTimer()
    }
    
    func stopRecordAudio() {
        audioRecordDeviceManager.stopRecordAudio()
    }
    
    func deleteRecordAudio() {
        
    }
    
    func deleteRecordAudio(audioPath: String) {
        
    }
    
    //MARK: AudioManagerDelegate
    func audioRecordBegin() {
        timeCounter = 0
        stopTimer()
    }
    
    func audioRecordEnd() {
        timeCounter = 0
        stopTimer()
        
        delegate?.audioRecordEnd(audioPath)
    }
    
    func audioRecordInterrupt() {
        stopTimer()
        
    }
    
    func audioRecordResume() {
        if timer == nil {
            startTimer()
        }
    }
}







