//
//  Response.swift
//  DRRoutes
//
//  Created by dr.box on 2022/3/10.
//

import Foundation

public enum Response {
    
    case nomatch
    case match(parameters: [String: Any])
}
