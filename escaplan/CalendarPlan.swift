//
//  CalendarPlan.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/11/25.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import RealmSwift

class calendarPlan: Object{
    //2017年12月25日の時　20171225
    dynamic var saveDay = ""
    //textViewの値を代入
    dynamic var plan = ""
    //selectDayをプライマリキーに設定
    override static func primaryKey() -> String?{
        return "saveDay"
    }
}
