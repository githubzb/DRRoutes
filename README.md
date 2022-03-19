# DRRoutes
采用swift实现的页面路由管理，它包括两部分。

第一部分：路由表（这部分借鉴了[JLRoutes](https://github.com/joeldev/JLRoutes)），适用于组件之前的解耦，它包括：

- 注册路由表（支持返回值）
- 调用路由
- 全局路由配置
- 路由404处理
- 取消路由注册
- 自定义路由匹配规则

第二部分：导航，适用于模块内部页面的跳转

- 定义导航页面
- 打开页面（push、present、openPage）
- 关闭页面（close）

### 第一部分

1、注册路由表：

- DRRoutes.globalRoutes.addRouter（全局路由注册）
- DRRoutes.routes(for: "Scheme").addRouter（自定义路由Scheme）

支持返回值，可以根据自身需要，决定返回什么类型的值。

```swift
DRRoutes.routes(for: "App").addRouter(pattern: "user/info/:userId") { parameters in
	print("user/info/:userId receive parameters: \(parameters)")
	if let userId = parameters["userId"] as? String, userId == "1234" {
		return .success(["name": "drbox", "age": 33]) // 指定返回值，你也可以为nil
	}else {
		return .fail("用户ID不存在") // 处理失败，这里可以返回错误信息
	}
}
```

2、调用路由

- routeResult（调用并返回结果，成功 or 失败）
- routeTarget（调用并返回指定的数据类型的数据）
- route（调用并返回成功与失败状态）

routeResult代码事例：

```swift
let res = DRRoutes.routeResult(url: URL(string: "App://user/info/1234")!)
switch res {
case .success(let optional):
    if let info = optional as? [String: Any] {
        print("result: \(info)")
    }else{
        print("result: \(optional == nil ? "is null." : "not [String: Any]")")
    }
case .fail(let optional):
    print("routeResult fail: \(optional ?? "")")
}
```

routeTarget代码事例：

```swift
if let res: [String: Any] = DRRoutes.routeTarget(url: URL(string: "App://user/info/1234")!) {
    print("res: \(res)")
}else {
    print("res is nil")
}
```

route事例代码：

```swift
if DRRoutes.route(url: URL(string: "App://user/info/1234")!) {
    print("匹配成功")
}else {
    print("匹配失败")
}
```

3、全局路由配置

- DRRoutes.globalRoutes（获取全局路由）
- Global.alwaysTreatsHostAsPathComponent（Configures if URL host is always considered to be a path component. Defaults to false.）
- Global.shouldDecodePlusSymbols（Configures if '+' should be replaced with spaces in parsed values. Defaults to true.）
- DRRoutes.routes(for: "Scheme").shouldFallbackToGlobalRoutes（指定当前Scheme路由未匹配到，是否交给全局路由处理，默认：false）

4、路由404处理

```swift
DRRoutes.globalRoutes.unmatchedURLHandler = { (routes, url, parameters) in
    print("App路由未匹配到，url: \(url), parameters: \(parameters)")
}
```

5、取消路由注册

- unregister（取消指定Scheme的路由表）
- unregisterAll（取消全部路由表）

6、自定义路由匹配规则

继承**DRRouter**定义规则

```swift
class MyRouter: DRRouter {
    
    // 自定义路由匹配规则
    override func routerResponse(for request: Request) -> Response {
        // 这里是你自定义的规则
        print("自定义匹配规则")
        return super.routerResponse(for: request)
    }
}
```

注册路由表，指定路由规则

```swift
// 自定义路由匹配规则
let routes = DRRoutes.routes(for: "App") { MyRouter(pattern: $0, priority: $1, handler: $2) }
routes.addRouter(pattern: "user/info/:userId") { parameters in
    if let userId = parameters["userId"] as? String, userId == "123" {
        return .success(["name": "liwei", "age": 25])
    }else {
        return .fail("用户ID不存在")
    }
}
```



### 第二部分

1、定义导航页面

导航页面只需实现**Pager**协议，Swift中一般采用枚举类型例如：

```swift
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
```

2、打开页面（push、present、openPage）

- push：它会自动根据rootViewController或指定的inViewController，获取到UINavigationController，调用push
- present：它会处理rootViewController或者指定的inViewController中是否存在presentedViewController，调用present
- openPage：它会根据rootViewController或者指定的inViewController具体情况，决定是采用push还是present打开页面

3、关闭页面（close）

- close：它会根据当前pager的具体情况，决定是采用哪种方式关闭当前页面，如：popViewController 或 dismiss
