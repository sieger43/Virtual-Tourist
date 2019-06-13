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
    init(photo:UIImage?, title:String)
    {
        self.photo = photo
        self.title = title
    }
    
    convenience init(photo:UIImage?) {
        self.init(photo: photo, title: "")
    }
    
    convenience init() {
        self.init(photo: nil, title: "")
    }
    
    var photo:UIImage?
    var title:String
}
