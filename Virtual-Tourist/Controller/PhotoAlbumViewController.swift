//
//  PhotoAlbumViewController.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/26/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//
import CoreLocation
import Foundation
import MapKit
import UIKit

class VirtualTouristModel {
    
    static var images = [UIImage]()
    
}

class PhotoAlbumViewController: UIViewController {
    
    private let reuseIdentifier = "FlickrCell"
    
    var lat:Double = 0.0;
    var lon:Double = 0.0;
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        centerMapOnLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.dataSource = self
        
        FlickrClient.getPhotoList(){ success, error, response in
            if success {
                print("Happy FlickrSearchResponse")
                
                if let thedata = response?.photos.photo {
                    
                    DispatchQueue.main.async(execute: {
                    
                        for photoRecord in thedata {
                            print("\(photoRecord.url_t)")
                            
                            let url = URL(string: photoRecord.url_t)
                            
                            if let unwrapped_URL = url {
                                

                                    do {
                                        let imageData = try Data(contentsOf: unwrapped_URL)
                                        if let image = UIImage(data: imageData) {
                                            VirtualTouristModel.images.append(image)
                                        }
                                    } catch {
                                        // empty
                                    }
                            }
                        }
                        
                        self.collectionView?.reloadData()
                    })

                }
                
            } else {
                let message = error?.localizedDescription ?? ""
                print("\(message)");
                print("Sad FlickrSearchResponse")
            }
        }
    }
    
    func centerMapOnLocation() {
        // from https://stackoverflow.com/questions/41639478/mkmapview-center-and-zoom-in?rq=1
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
        DispatchQueue.main.async {
            self.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = self.lat
            annotation.coordinate.longitude = self.lon
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("\(VirtualTouristModel.images.count)")
        
        return VirtualTouristModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PhotoCell
        print("bar")
        
        //2
        let photo = VirtualTouristModel.images[1]
        cell.backgroundColor = .white
        //3
        cell.imageView.image = photo
        
        return cell
    }

}
