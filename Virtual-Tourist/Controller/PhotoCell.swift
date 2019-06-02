//
//  PhotoCell.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/30/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //imageView = nil
        
    }
}
