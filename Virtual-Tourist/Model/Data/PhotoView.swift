//
//  PhotoView.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 6/12/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import Foundation
import UIKit

class PhotoView
{
    init(photo:UIImage?, index:Int32)
    {
        self.photo = photo
        self.index = index
    }
    
    convenience init(photo:UIImage?) {
        self.init(photo: photo, index: -1)
    }
    
    convenience init() {
        self.init(photo: nil, index: -1)
    }
    
    var photo:UIImage?
    var index:Int32
}
