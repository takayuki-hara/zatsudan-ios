//
//  SwiftyUserDefaultsExtension.swift
//  Zatsudan
//
//  Created by TakayukiHARA on 2016/05/29.
//  Copyright © 2016年 Hispot Co., LTD. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let userName = DefaultsKey<String>("userName")
    static let userKana = DefaultsKey<String>("userKana")
    static let userSex = DefaultsKey<Int>("userSex")
    static let userBlood = DefaultsKey<Int>("userBlood")
    static let userBirthDay = DefaultsKey<Date?>("userBirthDay")
    static let userArea = DefaultsKey<Int>("userArea")
    static let userLangage = DefaultsKey<Int>("userLangage")
}
