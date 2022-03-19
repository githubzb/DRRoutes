//
//  DRApplication.swift
//  DRRoutes
//
//  Created by dr.box on 2022/3/19.
//

import UIKit

open class DRApplication {
    
    struct Static {
        static let instance = DRApplication()
    }
    public static let shared = Static.instance
    
    public typealias Handler = (_ root: UIViewController)->Void
    private var handler: Handler? = nil
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    public func getRootViewController(_ handler: @escaping Handler) {
        if UIApplication.shared.applicationState == .active {
            if let root = rootViewController {
                handler(root)
            }
        }else{
            self.handler = handler
        }
    }
    
    public var rootViewController: UIViewController? { keyWindow?.rootViewController }
    
    public var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes
                .map({ $0 as! UIWindowScene })
                .filter({ $0.activationState == .foregroundActive })
                .first
            if #available(iOS 15.0, *) {
                return windowScene?.keyWindow
            } else {
                return windowScene?.windows.first
            }
        }else {
            return UIApplication.shared.keyWindow
        }
    }
    
    @objc
    private func didBecomeActive() {
        if let root = rootViewController {
            self.handler?(root)
            self.handler = nil
        }
    }
}
