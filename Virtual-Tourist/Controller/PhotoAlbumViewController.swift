//
//  PhotoAlbumViewController.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/26/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import Foundation

import UIKit

class PhotoAlbumViewController: UIViewController {
    
    private let reuseIdentifier = "FlickrCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.dataSource = self
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("foo")
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath)
        print("bar")
        
        return cell
    }

}
