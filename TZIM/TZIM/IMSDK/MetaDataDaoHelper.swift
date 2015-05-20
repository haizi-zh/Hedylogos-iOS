//
//  MetaDataDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol MetadataDaoHelperProtocol {
    func createAudioMessageTable(tableName: String)
}

class MetaDataDaoHelper: MetadataDaoHelperProtocol {
    private let dataBase: FMDatabase
    init(db: FMDatabase) {
        dataBase = db
    }
    
    /**
    创建存放语音的表
    :param: tableName 表的名称
    :returns: 是否创建成功
    */
    func createAudioMessageTable(tableName: String) {
        var sql = "create table 'VoiceTable' (UserId text, LocalId INTEGER, ServerUrl text, LocalPath text, Status int(4), Length INTEGER, CreateTime INTEGER)"
        if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
            println("success 执行 sql :\(sql)")
        } else {
            println("error 执行 sql :\(sql)")

        }
    }
}
