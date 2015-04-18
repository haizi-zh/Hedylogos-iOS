//
//  MetaDataDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol MetadataDaoHelperProtocol {
    func createAudioMessageTable(tableName: String) -> Bool
    func createImageMessageTable(tableName: String) -> Bool
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
    func createAudioMessageTable(tableName: String) -> Bool {
        if dataBase.open() {
            var sql = "create table '\(tableName)' (LocalId INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, ServerUrl text, LocalPath text, Status int(4), Length Float)"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                dataBase.close()
                return true
            } else {
                dataBase.close()
                return false
            }
        }
        return false
    }
    
    /**
    创建存放图片的表
    :param: tableName 表的名称
    :returns: 是否创建成功
    */
    func createImageMessageTable(tableName: String) -> Bool {
        if dataBase.open() {
            var sql = "create table '\(tableName)' (LocalId INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, ServerBigUrl text, ServerSmallUrl text, LocalPath text, Status int(4), width Float, height Float, ratio Float)"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                dataBase.close()
                return true
            } else {
                dataBase.close()
                return false
            }
        }
        return false
    }
}
