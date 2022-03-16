//
//  Request.swift
//  DRRoutes
//
//  Created by dr.box on 2022/3/7.
//

import Foundation

public struct RequestOptions: OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    /// 是否将参数中的+号替换成“ ”
    public static let decodePlusSymbols = RequestOptions(rawValue: 1 << 0)
    public static let treatHostAsPathComponent = RequestOptions(rawValue: 1 << 1)
}

public class Request {
    
    public let url: URL
    public let pathComponents: [String]
    public let queryParams: [String: Any]
    public let options: RequestOptions
    public let additionalParameters: [String: Any]?
    
    public init(url: URL, options: RequestOptions = [], parameters additionalParameters: [String: Any]?) {
        self.url = url
        self.options = options
        self.additionalParameters = additionalParameters
        
        let treatsHostAsPathComponent = options.contains(.treatHostAsPathComponent)
        guard let cpts = URLComponents(string: url.absoluteString) else {
            self.pathComponents = []
            self.queryParams = [:]
            return
        }
        var components = cpts
        if let host = components.host, !host.isEmpty,
            (treatsHostAsPathComponent || (host != "localhost" && !host.contains("."))) {
            // convert the host to "/" so that the host is considered a path component
            let ht = components.percentEncodedHost!
            components.host = "/"
            components.percentEncodedPath = ht.append(path: components.percentEncodedPath)
        }
        
        var path = components.percentEncodedPath
        // handle fragment if needed
        if let _ = components.fragment {
            if let _fragmentCompoents = URLComponents(string: components.percentEncodedFragment!) {
                var fragmentContainsQueryParams = false
                var fragmentCompoents = _fragmentCompoents
                if fragmentCompoents.query == nil && !fragmentCompoents.path.isEmpty {
                    fragmentCompoents.query = fragmentCompoents.path
                }
                if let qitems = fragmentCompoents.queryItems, qitems.count > 0 {
                    // determine if this fragment is only valid query params and nothing else
                    if let v = qitems.first?.value, v.count > 0 {
                        fragmentContainsQueryParams = true
                        components.queryItems = (components.queryItems ?? []) + qitems
                    }
                }
                
                if !fragmentCompoents.path.isEmpty && (!fragmentContainsQueryParams || fragmentCompoents.path != fragmentCompoents.query) {
                    // handle fragment by include fragment path as part of the main path
                    path += "#\(fragmentCompoents.percentEncodedPath)"
                }
            }
        }
        
        // split apart into path components
        self.pathComponents = path.trimPathComponent().components(separatedBy: "/")
        
        // convert query items into a dictionary
        if let items = components.queryItems, items.count > 0 {
            var queryParams: [String: Any] = [:]
            for item in items {
                guard let val = item.value else { continue }
                if let value = queryParams[item.name] as? String {
                    queryParams[item.name] = [value, val]
                }else if let _list = queryParams[item.name] as? [String] {
                    var list = _list
                    list.append(val)
                    queryParams[item.name] = list
                }else {
                    queryParams[item.name] = val
                }
            }
            self.queryParams = queryParams
        }else{
            self.queryParams = [:]
        }
    }
}

extension Request: CustomStringConvertible {
    
    public var description: String {
        "<\(type(of: self))> - URL: \(url.absoluteString)"
    }
}


extension String {
    
    func append(path pathComponent: String) -> String {
        if hasSuffix("/"), pathComponent.hasPrefix("/") {
            let end = index(endIndex, offsetBy: -1)
            return "\(self[startIndex ..< end])\(pathComponent)"
        }else if !hasSuffix("/") && !pathComponent.hasPrefix("/") {
            return "\(self)/\(pathComponent)"
        }
        return "\(self)\(pathComponent)"
    }
    
    @discardableResult
    mutating func trimPathComponent() -> String {
        trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}
