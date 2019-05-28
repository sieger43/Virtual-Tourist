//
//  FlickrSearchResponse.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/27/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import Foundation

struct FlickrSearchResponse: Codable {
    let photos: FlickPhotoInformation?
    let stat: String?
}

