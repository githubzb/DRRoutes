//
//  DRRouter.swift
//  DRRoutes
//
//  Created by dr.box on 2022/3/10.
//

import Foundation

public enum HandlerResult {
    case success(Any?)
    case fail(String?)
}

open class DRRouter {
    
    public typealias Handler = (_ parameters: [String: Any]) -> HandlerResult
    
    private(set) public var scheme: String = ""
    private(set) public var pattern: String
    private(set) public var priority: UInt
    private(set) public var patternPathComponents: [String]
    private(set) public var handler: Handler
    
    required public init(pattern: String, priority: UInt = 0, handler: @escaping Handler) {
        precondition(pattern.count > 0, "pattern can't be empty.")
        self.pattern = pattern
        self.priority = priority
        self.handler = handler
        guard pattern.count > 0 else {
            self.patternPathComponents = []
            return
        }
        var _pattern = pattern
        self.patternPathComponents = _pattern.trimPathComponent().components(separatedBy: "/")
    }
    
    func didBecomeRegistered(for scheme: String) {
        self.scheme = scheme
    }
    
    open func routerResponse(for request: Request) -> Response {
        if request.pathComponents.count != patternPathComponents.count &&
            !patternPathComponents.contains("*") {
            return .nomatch
        }
        guard let pathComponentVariables = routerPathComponentVariables(for: request) else {
            return .nomatch
        }
        return .match(parameters: matchParameters(for: request, variables: pathComponentVariables))
    }
    
    open func callHandler(parameters: [String: Any]) -> HandlerResult {
        handler(parameters)
    }
    
    public func matchParameters(for request: Request, variables pathComponentVariables: [String: String]) -> [String: Any] {
        var parameters = [String: Any]()
        let decodePlusSymbols = request.options.contains(.decodePlusSymbols)
        let queryParams = self.parameters(params: request.queryParams, decodePlusSymbols: decodePlusSymbols)
        parameters.merge(queryParams, uniquingKeysWith: { (_, last) in last })
        parameters.merge(pathComponentVariables, uniquingKeysWith: { (_, last) in last })
        if let params = request.additionalParameters {
            parameters.merge(params, uniquingKeysWith: { (_, last) in last })
        }
        parameters.merge(defaultMatchParameters(for: request), uniquingKeysWith: { (_, last) in last })
        return parameters
    }
    
    // 获取path中的参数，例如：/user/:userId
    public func routerPathComponentVariables(for request: Request) -> [String: String]? {
        
        var variables: [String: String]? = [String: String]()
        var i = 0
        var isMatch = true
        for patternPathComponent in patternPathComponents {
            let isPatternComponentWildcard = patternPathComponent == "*"
            var urlComponent: String?
            if i < request.pathComponents.count {
                urlComponent = request.pathComponents[i]
            }else if !isPatternComponentWildcard {
                isMatch = false
                break
            }
            
            if patternPathComponent.hasPrefix(":") {
                let varName = patternPathComponent.variableName
                var varValue = urlComponent?.variableValue
                if request.options.contains(.decodePlusSymbols) {
                    varValue = varValue?.decodePlusSymbols
                }
                if let val = varValue {
                    variables?[varName] = val
                }
            }else if isPatternComponentWildcard {
                // match wildcards
                if (request.pathComponents.count >= i) {
                    // match: /a/b/c/* has to be matched by at least /a/b/c
                    variables?[DRRoutes.Constant.wildcardComponentsKey] = request.pathComponents[i..<request.pathComponents.count - i].joined(separator: "/")
                    isMatch = true
                } else {
                    // not a match: /a/b/c/* cannot be matched by URL /a/b/
                    isMatch = false
                }
                break;
            }else if patternPathComponent != urlComponent {
                isMatch = false
                break
            }
            i += 1
        }
        
        if !isMatch {
            variables = nil
        }
        return variables
    }
    
    private func defaultMatchParameters(for request: Request) -> [String: Any] {
        [Global.DefaultKey.pattern: pattern,
         Global.DefaultKey.scheme: scheme,
         Global.DefaultKey.url: request.url]
    }
    
    private func parameters(params: [String: Any], decodePlusSymbols: Bool) -> [String: Any] {
        guard decodePlusSymbols else { return params }
        var resultParams = [String: Any]()
        for el in params {
            let key = el.key
            let val = el.value
            if let arr = val as? [String] {
                resultParams[key] = arr.map({ $0.decodePlusSymbols })
            }else if let str = val as? String {
                resultParams[key] = str.decodePlusSymbols
            }else {
                assert(false, "Unexpected query parameter type: \(val)")
            }
        }
        return resultParams
    }
    
}

extension DRRouter: CustomStringConvertible {
    
    public var description: String { "<\(type(of: self))> - \(pattern) (priority: \(priority))" }
}

extension DRRouter: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(scheme)
        hasher.combine(pattern)
        hasher.combine(priority)
        hasher.combine(patternPathComponents)
    }
}

extension DRRouter: Equatable {
    
    public static func == (lhs: DRRouter, rhs: DRRouter) -> Bool {
        return lhs.scheme == rhs.scheme &&
        lhs.pattern == rhs.pattern &&
        lhs.priority == rhs.priority &&
        lhs.patternPathComponents == rhs.patternPathComponents
    }
}

extension String {
    
    var variableName: String {
        var name = self
        if name.hasPrefix(":") {
            name.remove(at: startIndex)
        }
        if name.hasSuffix("#") {
            name.removeLast()
        }
        return name
    }
    
    var variableValue: String? {
        guard let _value = removingPercentEncoding else { return nil }
        var value = _value
        if value.hasSuffix("#") {
            value.removeLast()
        }
        return value
    }
    
    var decodePlusSymbols: String {
        replacingOccurrences(of: "+", with: " ", options: [.literal], range: nil)
    }
}
