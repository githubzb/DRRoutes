//
//  ViewController.swift
//  Test
//
//  Created by dr.box on 2022/3/3.
//

import UIKit
import DRRoutes

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册scheme为app的路由（支持可选路径）
        let pattern = "/the(/foo/:a)(/bar/:b)"
        DRRoutes.routes(for: "app").addRouter(pattern: pattern) { parameters in
            print("pattern: \(parameters)")
            return .success(nil)
        }
        
        // 设置当前路由不能处理时，交由全局路由处理
        DRRoutes.routes(for: "app").shouldFallbackToGlobalRoutes = true
        
        // 注册全局路由
        let pattern2 = "/user/info/:userId/"
        DRRoutes.globalRoutes.addRouter(pattern: pattern2) { parameters in
            print("pattern2: \(parameters)")
            return .success(nil)
        }
        
        // 为全局scheme路由设置未匹配到路由的回调
        DRRoutes.globalRoutes.unmatchedURLHandler = { (_, url, params)in
            print("unmatched: \(url), param: \(params)")
        }
        
        // 注册返回值的全局路由
        let pattern3 = "/age/:age"
        DRRoutes.globalRoutes.addRouter(pattern: pattern3) { parameters in
            
            return .success("name: \(parameters["name"] as? String ?? ""), age: \(parameters["age"] as? String ?? "")")
        }
        
        let url33 = URL(string: "app://age/34")!
        if let str: String = DRRoutes.routeTarget(url: url33, parameters: ["name": "drbox"]) {
            print("str: \(str)")
        }else{
            print("---str is null")
        }
        
//        let url_22 = URL(string: "app://setting")!
//        let res = DRRoutes.route(url: url_22, parameters: ["name": "drbox"])
//        print("res22: \(res ? "true" : "false")")
        
//        let url_21 = URL(string: "app://user/info/1234")!
//        if DRRoutes.route(url: url_21, parameters: ["name": "drbox"]) {
//            print("res21: true")
//        }else{
//            print("res21: false")
//        }
        
        
//        let url = URL(string: "app://the")!
//        if DRRoutes.route(url: url, parameters: ["name": "drbox"]) {
//            print("res1: true")
//        }else{
//            print("res1: false")
//        }
//
//        let url2 = URL(string: "app://the/foo/1234")!
//        if DRRoutes.route(url: url2, parameters: ["name": "drbox"]) {
//            print("res2: true")
//        }else {
//            print("res2: false")
//        }
//
//        let url3 = URL(string: "app://the/foo/1234/bar/3434")!
//        if DRRoutes.route(url: url3, parameters: ["name": "drbox"]) {
//            print("res3: true")
//        }else{
//            print("res3: false")
//        }
//
//        let url4 = URL(string: "app://the/bar/3434")!
//        if DRRoutes.route(url: url4, parameters: ["name": "drbox"]) {
//            print("res4: true")
//        }else {
//            print("res4: false")
//        }
        
    }
}





