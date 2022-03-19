//
//  DRNavigator.swift
//  DRRoutes
//
//  Created by dr.box on 2022/3/16.
//

import UIKit

// 页面
public protocol Pager {
    
    var viewController: UIViewController { get }
}

public class DRNavigator {
    
    private static func _push(page: UIViewController, in viewController: UIViewController, animated: Bool = true) -> Bool {
        if let navVc = viewController as? UINavigationController {
            navVc.pushViewController(page, animated: animated)
            return true
        }
        guard let navVc = viewController.navigationController else {
            return false
        }
        navVc.pushViewController(page, animated: animated)
        return true
    }
    
    private static func _present(page: UIViewController, in viewController: UIViewController, animated: Bool = true, modalStyle: UIModalPresentationStyle = .fullScreen) {
        page.modalPresentationStyle = modalStyle
        
        var presentedVc = viewController
        while presentedVc.presentedViewController != nil {
            presentedVc = presentedVc.presentedViewController!
        }
        presentedVc.present(page, animated: animated, completion: nil)
    }
}

extension DRNavigator {
    
    public static func push(pager: Pager, animated: Bool = true) {
        DRApplication.shared.getRootViewController { root in
            if let nav = root as? UINavigationController {
                DRNavigator.push(pager: pager, in: nav, animated: animated)
            }else if let tabbarVc = root as? UITabBarController,
                     let nav = tabbarVc.selectedViewController as? UINavigationController {
                DRNavigator.push(pager: pager, in: nav, animated: animated)
            }else{
                fatalError("rootViewController can't push \(pager.viewController)")
            }
        }
    }
    public static func present(pager: Pager, animated: Bool = true, modalStyle: UIModalPresentationStyle = .fullScreen) {
        DRApplication.shared.getRootViewController { root in
            DRNavigator.present(pager: pager, in: root, animated: animated, modalStyle: modalStyle)
        }
    }
    public static func openPage(pager: Pager, animated: Bool = true) {
        DRApplication.shared.getRootViewController { root in
            DRNavigator.openPage(pager: pager, in: root, animated: animated)
        }
    }
    
    
    @discardableResult
    public static func push(pager: Pager, in viewController: UIViewController, animated: Bool = true) -> Bool {
        _push(page: pager.viewController, in: viewController)
    }
    
    public static func present(pager: Pager, in viewController: UIViewController, animated: Bool = true, modalStyle: UIModalPresentationStyle = .fullScreen) {
        _present(page: pager.viewController, in: viewController, animated: animated, modalStyle: modalStyle)
    }
    
    public static func openPage(pager: Pager, in viewController: UIViewController, animated: Bool = true) {
        let page = pager.viewController
        if !_push(page: page, in: viewController) {
            _present(page: page, in: viewController, animated: animated, modalStyle: .fullScreen)
        }
    }
    
    @discardableResult
    public static func close(page: UIViewController, animated: Bool = true) -> Bool {
        if let nav = page.navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: animated)
            return true
        }
        if page.presentingViewController != nil {
            page.dismiss(animated: animated, completion: nil)
            return true
        }
        return false
    }
}

