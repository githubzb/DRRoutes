//
//  TestRoutesViewController.swift
//  Test
//
//  Created by dr.box on 2022/3/19.
//

import Foundation
import UIKit
import DrFlexLayout_swift
import DRRoutes

class TestRoutesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 40)).define { flex in
                let btn = flex.view as! UIButton
                btn.layer.cornerRadius = 20
                btn.backgroundColor = .blue
                btn.setTitle("关闭", for: .normal)
                btn.setTitleColor(.white, for: .normal)
                btn.addTarget(self, action: #selector(clickCloseBtn), for: .touchUpInside)
            }
        }
        runTest()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.dr_flex.layout()
    }
    
    @objc private func clickCloseBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func runTest() {
//        test1()
//        test2()
//        test3()
//        test4()
//        test5()
//        test6()
//        test7()
//        test8()
        test9()
    }
    
    func test1() {
        // 注册全局路由
        DRRoutes.globalRoutes.addRouter(pattern: "setting/config") { parameters in
            print("setting/config receive paramters: \(parameters)")
            return .success(["version": "1.0.2", "isActive": true])
        }
        // 匹配全局路由
        let res = DRRoutes.routeResult(url: URL(string: "global://setting/config")!, parameters: ["name": "drbox", "pwd": "abcd"])
        switch res {
        case .success(let optional):
            print("global://setting/config routeResult success.")
            if let map = optional as? [String: Any] {
                print("result: \(map)")
            }else{
                print("result: \(optional == nil ? "is null." : "not [String: Any]")")
            }
        case .fail(let optional):
            print("global://setting/config routeResult fail: \(optional ?? "")")
        }
    }
    
    func test2() {
        // 注册全局路由
        DRRoutes.globalRoutes.addRouter(pattern: "setting/config/:name/:pwd") { parameters in
            print("setting/config receive paramters: \(parameters)")
            return .success(["version": "1.0.2", "isActive": true])
        }
        // 匹配全局路由错误（url中应该带上参数值）
        let res = DRRoutes.routeResult(url: URL(string: "global://setting/config")!, parameters: nil)
        // 匹配全局路由，parameters中的key会覆盖url中的参数
//        let res = DRRoutes.routeResult(url: URL(string: "global://setting/config/drbox1/1234")!, parameters: ["name": "drbox", "pwd": "abcd"])
        // 正常匹配路由
//        let res = DRRoutes.routeResult(url: URL(string: "global://setting/config/drbox1/1234")!, parameters: nil)
        switch res {
        case .success(let optional):
            print("global://setting/config routeResult success.")
            if let map = optional as? [String: Any] {
                print("result: \(map)")
            }else{
                print("result: \(optional == nil ? "is null." : "not [String: Any]")")
            }
        case .fail(let optional):
            print("global://setting/config routeResult fail: \(optional ?? "")")
        }
    }
    
    func test3() {
        // 注册指定scheme的路由
        DRRoutes.routes(for: "App").addRouter(pattern: "user/info/:userId") { parameters in
            print("user/info/:userId receive parameters: \(parameters)")
            if let userId = parameters["userId"] as? String, userId == "1234" {
                return .success(["name": "drbox", "age": 33])
            }else {
                return .fail("用户ID不存在")
            }
        }
        
        // 正常匹配路由
//        let res = DRRoutes.routes(for: "App").routeResult(url: URL(string: "App://user/info/1234")!)
        // 匹配失败
//        let res = DRRoutes.routes(for: "App").routeResult(url: URL(string: "App://user/1234")!)
        // scheme 不匹配
//        let res = DRRoutes.routes(for: "Test").routeResult(url: URL(string: "App://user/info/1234")!)
        // 无需指定scheme，也可以正常匹配
        let res = DRRoutes.routeResult(url: URL(string: "App://user/info/1234")!)
        
        switch res {
        case .success(let optional):
            print("user/info/:userId routeResult success.")
            if let info = optional as? [String: Any] {
                print("result: \(info)")
            }else{
                print("result: \(optional == nil ? "is null." : "not [String: Any]")")
            }
        case .fail(let optional):
            print("user/info/:userId routeResult fail: \(optional ?? "")")
        }
    }
    
    func test4(){
        
        // 注册两个相同的路由，可以设置其优先级，使其优先进行匹配到
        // 默认优先级0
        DRRoutes.routes(for: "App").addRouter(pattern: "user/info/:userId") { parameters in
            print("A user/info/:userId receive parameters: \(parameters)")
            if let userId = parameters["userId"] as? String, userId == "1234" {
                return .success(["name": "drbox", "age": 33])
            }else {
                return .fail("用户ID不存在A")
            }
        }
        // 这里设置优先级为1的相同路由（会优先进行匹配）
        DRRoutes.routes(for: "App").addRouter(pattern: "user/info/:userId", priority: 1){ (parameters) in
            print("B user/info/:userId receive parameters: \(parameters)")
            if let userId = parameters["userId"] as? String, userId == "123" {
                return .success(["name": "liwei", "age": 25])
            }else {
                return .fail("用户ID不存在B")
            }
        }
        
        // 以下只会匹配优先级高的路由
        
        // userId = 123，匹配优先级高的路由
//        let res = DRRoutes.routeResult(url: URL(string: "App://user/info/123")!)
        // userId = 1234，匹配优先级高的路由
        let res = DRRoutes.routeResult(url: URL(string: "App://user/info/1234")!)
        switch res {
        case .success(let optional):
            print("App://user/info/1234 routeResult success.")
            if let info = optional as? [String: Any] {
                print("result: \(info)")
            }else{
                print("result: \(optional == nil ? "is null." : "not [String: Any]")")
            }
        case .fail(let optional):
            print("user/info/:userId routeResult fail: \(optional ?? "")")
        }
        
    }
    
    func test5() {
        // 注册可选路由（即：匹配多个URL）
        let pattern = "/user/(/info/:userId)(/info/detail/:userId)"
        DRRoutes.routes(for: "App").addRouter(pattern: pattern) { parameters in
            print("/user/(/info/:userId)(/info/detail/:userId) receive parameters: \(parameters)")
            if let userId = parameters["userId"] as? String, userId == "123" {
                return .success(["name": "liwei", "age": 25])
            }else {
                return .fail("用户ID不存在")
            }
        }
        
        // 第一种URL，成功匹配
//        let res = DRRoutes.routeResult(url: URL(string: "App://user/info/123")!)
        // 第二种URL，成功匹配
        let res = DRRoutes.routeResult(url: URL(string: "App://user/info/detail/123")!)
        switch res {
        case .success(let optional):
            print("App://user/info/1234 routeResult success.")
            if let info = optional as? [String: Any] {
                print("result: \(info)")
            }else{
                print("result: \(optional == nil ? "is null." : "not [String: Any]")")
            }
        case .fail(let optional):
            print("routeResult fail: \(optional ?? "")")
        }
    }
    
    func test6() {
        // 注册全局路由
        DRRoutes.globalRoutes.addRouter(pattern: "user/info/:userId") { parameters in
            print("global receive parameters: \(parameters)")
            if let userId = parameters["userId"] as? String, userId == "123" {
                return .success(["name": "global_liwei", "age": 25])
            }else {
                return .fail("global 用户ID不存在")
            }
        }
        
        DRRoutes.routes(for: "App").addRouter(pattern: "user/detail/:userId") { parameters in
            print("App receive parameters: \(parameters)")
            if let userId = parameters["userId"] as? String, userId == "123" {
                return .success(["name": "App_liwei", "age": 25])
            }else {
                return .fail("App 用户ID不存在")
            }
        }
        
        // App路由未匹配，重定向到全局路由
        DRRoutes.routes(for: "App").shouldFallbackToGlobalRoutes = true
        
        // App路由匹配失败，重定向到全局路由
//        let res = DRRoutes.routeResult(url: URL(string: "App://user/info/123")!)
        // App路由正常匹配
        let res = DRRoutes.routeResult(url: URL(string: "App://user/detail/123")!)
        switch res {
        case .success(let optional):
            print("routeResult success.")
            if let info = optional as? [String: Any] {
                print("result: \(info)")
            }else{
                print("result: \(optional == nil ? "is null." : "not [String: Any]")")
            }
        case .fail(let optional):
            print("routeResult fail: \(optional ?? "")")
        }
    }
    
    func test7() {
        // 注册App路由
        DRRoutes.routes(for: "App").addRouter(pattern: "user/info/:userId") { parameters in
            print("App receive parameters: \(parameters)")
            if let userId = parameters["userId"] as? String, userId == "123" {
                return .success(["name": "App_liwei", "age": 25])
            }else {
                return .fail("App 用户ID不存在")
            }
        }
        
        // 设置App路由未匹配到的回调
        DRRoutes.routes(for: "App").unmatchedURLHandler = { (routes, url, parameters) in
            print("App路由未匹配到，url: \(url), parameters: \(parameters)")
        }
        
        // URL不在路由表中
        if DRRoutes.route(url: URL(string: "App://user/detail/123")!) {
            print("匹配成功")
        }else {
            print("匹配失败")
        }
        
    }
    
    func test8() {
        // 注册全局路由
        DRRoutes.globalRoutes.addRouter(pattern: "/config") { parameters in
            return .success(["version": "1.2.3", "user_name": "drbox", "pwd": "11111"])
        }
        
        // 直接转化路由结果
        if let res: [String: Any] = DRRoutes.routeTarget(url: URL(string: "App://config")!) {
            print("res: \(res)")
        }else {
            print("res is nil")
        }
    }
    
    func test9() {
        
        // 自定义路由匹配规则
        let routes = DRRoutes.routes(for: "App") { MyRouter(pattern: $0, priority: $1, handler: $2) }
        routes.addRouter(pattern: "user/info/:userId") { parameters in
            if let userId = parameters["userId"] as? String, userId == "123" {
                return .success(["name": "liwei", "age": 25])
            }else {
                return .fail("用户ID不存在")
            }
        }
        
        // 直接转化路由结果
        if let res: [String: Any] = DRRoutes.routeTarget(url: URL(string: "App://user/info/123")!) {
            print("res: \(res)")
        }else {
            print("res is nil")
        }
        
    }
}


class MyRouter: DRRouter {
    
    // 自定义路由匹配规则
    override func routerResponse(for request: Request) -> Response {
        // 这里是你自定义的规则
        print("自定义匹配规则")
        return super.routerResponse(for: request)
    }
}
