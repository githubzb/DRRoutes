//
//  Pagers.swift
//  Test
//
//  Created by dr.box on 2022/3/19.
//

import UIKit
import DRRoutes

// 定义导航页面
enum Pagers: Pager {
    
    case user(userId: String)
    case setting
    
    var viewController: UIViewController {
        switch self {
        case let .user(userId):
            return UserViewController(userId: userId)
        case .setting:
            return SettingViewController()
        }
    }
}
