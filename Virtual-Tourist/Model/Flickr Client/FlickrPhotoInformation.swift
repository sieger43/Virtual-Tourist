//
//  FlickrPhotoInformation.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/27/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import Foundation

struct FlickPhotoInformation : Codable {
    let page : Int
    let pages : Int
    let perpage : Int
    let total : String
    let photo : [FlickrPhotoRecord]
}

