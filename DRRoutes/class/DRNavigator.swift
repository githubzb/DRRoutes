//
//  DRNavigator.swift
//  DRRoutes
//
//  Created by dr.box on 2022/3/16.
//

import UIKit

// 导航
public protocol Navigator {
    
    var viewController: UIViewController { get }
}

public class DRNavigator {
    
    public static func push(nav: Navigator, animated: Bool = true) {
        
    }
    public static func push(nav: Navigator, in viewController: UIViewController, animated: Bool = true) {
        if let navVc = viewController as? UINavigationController {
            navVc.pushViewController(nav.viewController, animated: animated)
            return
        }
        guard let navVc = viewController.navigationController else {
            return
        }
        navVc.pushViewController(nav.viewController, animated: animated)
    }
    
    public static func present(nav: Navigator, in viewController: UIViewController, animated: Bool = true, modalStyle: UIModalPresentationStyle = .fullScreen) {
        viewController.modalPresentationStyle = modalStyle
        viewController.present(nav.viewController, animated: animated, completion: nil)
    }
    
}

