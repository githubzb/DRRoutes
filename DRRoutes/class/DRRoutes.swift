//
//  DRRoutes.swift
//  DRRoutes
//
//  Created by dr.box on 2022/3/3.
//

import Foundation

public final class DRRoutes: CustomStringConvertible {
    
    public typealias RouterBuilder = (_ pattern: String, _ priority: UInt, _ handler: @escaping DRRouter.Handler)->DRRouter
    public typealias UnmatchedURLHandler = (_ routes: DRRoutes, _ url: URL, _ parameters: [String: Any]?) -> Void
    
    public var description: String { routers.description }
    
    /// 当非全局scheme的路由未匹配到时，交给全局路由处理
    public var shouldFallbackToGlobalRoutes: Bool = false
    /// 当没有任何一个路由可以处理时的回调
    public var unmatchedURLHandler: UnmatchedURLHandler?
    
    /// 是否是全局scheme
    var isGlobalRoutes: Bool { scheme == Constant.globalSchemeKey }
    
    let scheme: String
    public var routers: [DRRouter] = []
    var routerBuilder: RouterBuilder
    
    init(scheme: String, routerBuilder: @escaping RouterBuilder) {
        self.scheme = scheme
        self.routerBuilder = routerBuilder
    }
    
    struct Constant {
        static let globalSchemeKey = "_DRGlobalRoutesScheme"
        /// 匹配*后面的pathComponents
        static let wildcardComponentsKey = "_DRWildcardComponentsKey"
    }
    
}

// MARK: - 对外提供方法
extension DRRoutes {
    
    public static var allRoutes: [String: [DRRouter]] {
        Global.allRoutes.reduce([String: [DRRouter]](), { $0.merging([$1.key: $1.value.routers], uniquingKeysWith: { (_, last) in last }) })
    }
    /// 获取全局scheme的routes
    public static var globalRoutes: DRRoutes { routes(for: Constant.globalSchemeKey) }
    
    /// 获取指定scheme的routes
    @discardableResult
    public static func routes(for scheme: String, routerBuilder: @escaping RouterBuilder = {DRRouter(pattern: $0, priority: $1, handler: $2)}) -> DRRoutes {
        let routes: DRRoutes
        if Global.hasRoute(for: scheme) {
            routes = Global.route(for: scheme)!
        }else{
            routes = DRRoutes(scheme: scheme, routerBuilder: routerBuilder)
            Global.register(routes: routes, for: scheme)
        }
        return routes
    }
    
    /// 注销scheme的routes
    public static func unregister(for scheme: String) {
        Global.unregister(for: scheme)
    }
    /// 注销全部routes
    public static func unregisterAll() {
        Global.unregisterAll()
    }
    
    public func addRouter(_ router: DRRouter) {
        if router.priority == 0 || routers.count == 0 {
            routers.append(router)
        }else {
            var i = 0
            var addedRouter = false
            
            // search through existing routes looking for a lower priority route than this one
            for _router in routers {
                if (_router.priority < router.priority) {
                    // if found, add the route after it
                    routers.insert(router, at: i)
                    addedRouter = true
                    break;
                }
                i += 1
            }
            
            // if we weren't able to find a lower priority route, this is the new lowest priority route (or same priority as self.routes.lastObject) and should just be added
            if (!addedRouter) {
                routers.append(router)
            }
        }
        router.didBecomeRegistered(for: scheme)
    }
    
    public func addRouter(pattern: String, priority: UInt = 0, handler: @escaping DRRouter.Handler) {
        let router = routerBuilder(pattern, priority, handler)
        let optionalRoutePatterns = expandOptionalRoutePatterns(pattern: pattern)
        
        if optionalRoutePatterns.count > 0 {
            for _pattern in optionalRoutePatterns {
                let _router = routerBuilder(_pattern, priority, handler)
                addRouter(_router)
            }
            return
        }
        addRouter(router)
    }
    
    public func addRouters(patterns: [String], handler: @escaping DRRouter.Handler) {
        for pattern in patterns {
            addRouter(pattern: pattern, handler: handler)
        }
    }
    
    public func removeRouter(_ router: DRRouter) {
        if let idx = routers.firstIndex(where: { $0 == router }) {
            routers.remove(at: idx)
        }
    }
    
    public func removeRouter(pattern: String) {
        if let idx = routers.firstIndex(where: { $0.pattern == pattern }) {
            routers.remove(at: idx)
        }
    }
    
    public func removeAllRouters() {
        routers.removeAll()
    }
    
    public func canRoute(url: URL) -> Bool {
        let options = _routeRequestOptions
        let request = Request(url: url, options: options, parameters: nil)
        var can = false
        for router in routers {
            switch router.routerResponse(for: request) {
            case .nomatch:
                continue
            case .match(_):
                break
            }
            can = true
        }
        return can
    }
    
    public func routeResult(url: URL, parameters: [String: Any]? = nil) -> HandlerResult {
        let options = _routeRequestOptions
        let request = Request(url: url, options: options, parameters: parameters)
        var res: HandlerResult = .fail(nil)
    forlabel:for router in routers {
            switch router.routerResponse(for: request) {
            case .nomatch:
                continue forlabel
            case let .match(params):
                res = router.callHandler(parameters: params)
                break forlabel
            }
        }
        if case .fail(_) = res, (shouldFallbackToGlobalRoutes && !isGlobalRoutes) {
            res = DRRoutes.globalRoutes.routeResult(url: url, parameters: parameters)
        }
        if case .fail(_) = res, let call = self.unmatchedURLHandler {
            call(self, url, parameters)
        }
        return res
    }
    
    public func routeTarget<T>(url: URL, parameters: [String: Any]? = nil) -> T? {
        switch routeResult(url: url, parameters: parameters) {
        case .fail(_):
            return nil
        case let .success(target):
            return target as? T
        }
    }
    
    @discardableResult
    public func route(url: URL, parameters: [String: Any]? = nil) -> Bool {
        switch routeResult(url: url, parameters: parameters) {
        case .fail(_):
            return false
        case .success(_):
            return true
        }
    }
    
    
    static public func canRoute(url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }
        return (Global.route(for: scheme) ?? globalRoutes).canRoute(url: url)
    }
    
    @discardableResult
    static public func route(url: URL, parameters: [String: Any]? = nil) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }
        return (Global.route(for: scheme) ?? globalRoutes).route(url: url, parameters: parameters)
    }
    
    static public func routeResult(url: URL, parameters: [String: Any]? = nil) -> HandlerResult {
        guard let scheme = url.scheme else {
            return .fail("url.scheme can't be empty")
        }
        return (Global.route(for: scheme) ?? globalRoutes).routeResult(url: url, parameters: parameters)
    }
    
    static public func routeTarget<T>(url: URL, parameters: [String: Any]? = nil) -> T? {
        guard let scheme = url.scheme else {
            return nil
        }
        return (Global.route(for: scheme) ?? globalRoutes).routeTarget(url: url, parameters: parameters)
    }
}

extension DRRoutes {
    
    private var _routeRequestOptions: RequestOptions {
        var options: RequestOptions = []
        if Global.shouldDecodePlusSymbols {
            options.formUnion(.decodePlusSymbols)
        }
        if Global.alwaysTreatsHostAsPathComponent {
            options.formUnion(.treatHostAsPathComponent)
        }
        return options
    }
}


extension DRRoutes {
    
    private func expandOptionalRoutePatterns(pattern: String) -> [String] {
        // for the route /the(/foo/:a)(/bar/:b), it will register the following routes:
        // /the/foo/:a/bar/:b
        // /the/foo/:a
        // /the
        guard pattern.contains("(") else {
            return []
        }
        let subPaths = routeSubpaths(pattern: pattern)
        guard subPaths.count > 0 else {
            return []
        }
        
        let requiredSubpaths = Set(subPaths.filter({ !$0.isOptionalSubpath }))
        let allSubpathCombinations = subPaths.allOrderedCombinations
        let validSubpathCombinations = allSubpathCombinations.filter({ requiredSubpaths.isSubset(of: $0) })
        var validSubpathRouteStrings = validSubpathCombinations.map { (list) -> String in
            var routePattern = "/"
            for _subpath in list {
                routePattern = routePattern.append(path: _subpath.subpathComponents.joined(separator: "/"))
            }
            return routePattern;
        }
        validSubpathRouteStrings = validSubpathRouteStrings.sorted(by: { $0.count > $1.count })
        return validSubpathRouteStrings
    }
    
    private func routeSubpaths(pattern: String) -> [RouterSubPath] {
        var subPaths: [RouterSubPath] = []
        
        let scanner = Scanner(string: pattern)
        while !scanner.isAtEnd {
            
            let preOptionalSubpath = scanner.scanUpToStr("(")
            if !scanner.isAtEnd {
                scanner.next()
            }
            if let path = preOptionalSubpath, path.count > 0, path != ")", path != "/" {
                let subPath = RouterSubPath(subpathComponents: path.trimmedPathComponents())
                subPaths.append(subPath)
            }
            
            if scanner.isAtEnd {
                break
            }
            
            if let optionalSubpath = scanner.scanUpToStr(")") {
                scanner.next()
                if optionalSubpath.count > 0 {
                    let subPath = RouterSubPath(subpathComponents: optionalSubpath.trimmedPathComponents(), isOptional: true)
                    subPaths.append(subPath)
                }
            }else{
                assert(false, "Could not find closing )")
            }
        }
        return subPaths
    }
    
    
    struct RouterSubPath {
        let subpathComponents: [String]
        let isOptionalSubpath: Bool
        
        init(subpathComponents: [String], isOptional: Bool = false) {
            self.subpathComponents = subpathComponents
            self.isOptionalSubpath = isOptional
        }
    }
}

extension DRRoutes.RouterSubPath: CustomStringConvertible {
    
    var description: String {
        "\(type(of: self)) - \(isOptionalSubpath ? "OPTIONAL" : "REQUIRED") : \(subpathComponents.joined(separator: "/"))"
    }
}

extension DRRoutes.RouterSubPath: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(subpathComponents)
        hasher.combine(isOptionalSubpath)
    }
}

extension DRRoutes.RouterSubPath: Equatable {
    static func == (lhs: DRRoutes.RouterSubPath, rhs: DRRoutes.RouterSubPath) -> Bool {
        lhs.subpathComponents == rhs.subpathComponents && lhs.isOptionalSubpath == rhs.isOptionalSubpath
    }
}


// MARK: - ---------------Global---------------
typealias RouteMap = [String: DRRoutes]

public final class Global {
    
    private static let share = Global()
    
    var map = RouteMap()
    var _shouldDecodePlusSymbols = true
    var _alwaysTreatsHostAsPathComponent = false
    
    static func hasRoute(for scheme: String) -> Bool {
        guard let _ = share.map.first(where: { $0.key == scheme }) else {
            return false
        }
        return true
    }
    
    static func route(for scheme: String) -> DRRoutes? { share.map[scheme] }
    static func register(routes: DRRoutes, for scheme: String) {
        share.map[scheme] = routes
    }
    static func unregister(for scheme: String) {
        share.map[scheme] = nil
    }
    static func unregisterAll() {
        share.map = RouteMap()
    }
    static var allRoutes: RouteMap { share.map }
    
    /// Configures if '+' should be replaced with spaces in parsed values. Defaults to true.
    public static var shouldDecodePlusSymbols: Bool {
        set {
            share._shouldDecodePlusSymbols = newValue
        }
        get {
            share._shouldDecodePlusSymbols
        }
    }
    
    /// Configures if URL host is always considered to be a path component. Defaults to false.
    public static var alwaysTreatsHostAsPathComponent: Bool {
        set {
            share._alwaysTreatsHostAsPathComponent = newValue
        }
        get {
            share._alwaysTreatsHostAsPathComponent
        }
    }
    
    public struct DefaultKey {
        public static let pattern = "DRRouterPattern"
        public static let url = "DRRouterURL"
        public static let scheme = "DRRouterScheme"
    }
    
}


extension Scanner {
    
    func scanUpToStr(_ substring: String) -> String? {
        if #available(iOS 13.0, *) {
            return scanUpToString(substring)
        } else {
            var str: NSString?
            if scanUpTo(substring, into: &str) {
                return str as String?
            }
            return nil
        }
    }
    
    func next() {
        if #available(iOS 13.0, *) {
            currentIndex = string.index(after: currentIndex)
        }else {
            scanLocation += 1
        }
    }
}

extension String {
    
    func trimmedPathComponents() -> [String] {
        trimmingCharacters(in: CharacterSet(charactersIn: "/")).components(separatedBy: "/")
    }
}


extension Array {
    
    var allOrderedCombinations: [[Element]] {
        guard count > 0 else {
            return [[]]
        }
        let lastObj = last!
        let subArray = Array(self[0..<count-1])
        let subarrayCombinations = subArray.allOrderedCombinations
        var combinations = subarrayCombinations
        for arr in subarrayCombinations {
            var subarrayCombos = arr
            subarrayCombos.append(lastObj)
            combinations.append(subarrayCombos)
        }
        return combinations
    }
}
