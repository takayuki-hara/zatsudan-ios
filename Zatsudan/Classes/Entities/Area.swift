//
//  Area.swift
//  Zatsudan
//
//  Created by TakayukiHARA on 2016/05/29.
//  Copyright © 2016年 Hispot Co., LTD. All rights reserved.
//

import Foundation

@objc enum Area: Int {
    case sapporo, fukushima, tokyo, yokohama, nagano, kyoto, osaka, hiroshima, nagasaki, naha, kaigai
    
    func toString() -> String {
        switch self {
        case .sapporo:      return "札幌"
        case .fukushima:    return "福島"
        case .tokyo:        return "東京"
        case .yokohama:     return "横浜"
        case .nagano:       return "長野"
        case .kyoto:        return "京都"
        case .osaka:        return "大阪"
        case .hiroshima:    return "広島"
        case .nagasaki:     return "長崎"
        case .naha:         return "那覇"
        case .kaigai:       return "海外"
        }
    }
    
    static let count: Int = {
        var i = 0
        while let _ = Area(rawValue: i) { i += 1 }
        return i
    }()
    
}
