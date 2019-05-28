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
    let url_m : String?
    let height_m : String?
    let width_m : String?
    
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
        case url_m
        case height_m
        case width_m
    }
}
