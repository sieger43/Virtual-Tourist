//
//  FlickrErrorResponse.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/27/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import Foundation

struct FlickrErrorResponse: Codable {
    
    // { "stat": "fail", "code": 99, "message": "Insufficient permissions. Method requires read privileges; none granted." }
    
    let stat: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case stat
        case code
        case message
    }
}

extension FlickrErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
