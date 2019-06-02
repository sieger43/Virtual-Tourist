//
//  FlickrPhotoRecord.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/27/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import Foundation

struct FlickrPhotoRecord : Codable {
    
    let id : String?
    let owner : String?
    let secret : String?
    let server : String?
    let farm : Int?
    let title : String?
    let ispublic : Int?
    let isfriend : Int?
    let isfamily : Int?
    let url_s : String
    let height_t : String?
    let width_t : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
        case url_s
        case height_t
        case width_t
    }
}
