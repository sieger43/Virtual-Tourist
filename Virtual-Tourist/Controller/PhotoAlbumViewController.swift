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
import CoreData

class VirtualTouristModel {
    
    static var images = [PhotoView]()
    
}

class PhotoAlbumViewController: UIViewController {
    
    private let reuseIdentifier = "FlickrCell"
    
    var lat:Double = 0.0;
    var lon:Double = 0.0;
    
    var dataController:DataController!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VirtualTouristModel.images.removeAll()

        collectionView.dataSource = self
        mapView.delegate = self
        
        refreshPhotoList()
    }

    func refreshPhotoList() {
 
        var haveCachedPhotos = false;
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let latPredicate = NSPredicate(format: "latitude = %@", argumentArray: [lat])
        let lonPredicate = NSPredicate(format: "longitude = %@", argumentArray: [lon])
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [latPredicate, lonPredicate])
        
        fetch.predicate = andPredicate
        
        var mapPin : Pin? = nil
        
        do {
            let result = try dataController.viewContext.fetch(fetch)
            
            if result.count == 1 {
                let p : Pin = result[0] as! Pin
                
                mapPin = p
                
                if let theSet = p.photos {
                    let numPhotos = theSet.count
                    if numPhotos == 0 {
                        haveCachedPhotos = false
                    } else {
                        
                        for case let photo as Photo in theSet  {
                            if let imageData = photo.imageData, let image = UIImage(data: imageData),
                                let photoTitle = photo.title {
                                VirtualTouristModel.images.append(PhotoView(photo: image, title: photoTitle))
                            }
                        }
                        
                        VirtualTouristModel.images.sort(by: { $0.title > $1.title })
                        
                        haveCachedPhotos = true
                        
                        self.centerMapOnLocation()
                        self.collectionView?.reloadData()
                    }
                }
           }
        } catch {
            let _ = "refreshPhotoList() Failed"
        }
        
        if !haveCachedPhotos {

            FlickrClient.getPhotoList(lat: lat, lon: lon){ success, error, response in
                if success {
                    
                    if let thedata = response?.photos.photo {
                        
                        DispatchQueue.main.async(execute: {
                            for photoRecord in thedata {
                                
                                let url = URL(string: photoRecord.url_s)
                                
                                if let unwrapped_URL = url, let photoTitle =  photoRecord.title {

                                    do {
                                        let imageData = try Data(contentsOf: unwrapped_URL)
                                        if let image = UIImage(data: imageData) {
                                            VirtualTouristModel.images.append(PhotoView(photo: image, title: photoTitle))
                                        }
                                    } catch {
                                        // empty
                                    }
                                }
                            }
                            
                            VirtualTouristModel.images.sort(by: { $0.title > $1.title })
                            
                            if !haveCachedPhotos {
                                if let p = mapPin {
                                    for photoView in VirtualTouristModel.images {
                                        if let pic = photoView.photo  {
                                            let d = pic.pngData()
                                            let photo = Photo(context: self.dataController.viewContext)
                                            photo.imageData = d
                                            photo.title = photoView.title
                                            p.addToPhotos(photo)
                                        }
                                    }
                                    try? self.dataController.viewContext.save()
                                }
                            }
                            
                            self.centerMapOnLocation()
                            self.collectionView?.reloadData()
                        })
                    }
                    
                } else {
                    let _ = error?.localizedDescription ?? ""
                }
            }
        }
    }
    
    private func centerMapOnLocation() {
        // from https://stackoverflow.com/questions/41639478/mkmapview-center-and-zoom-in?rq=1
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))

        self.mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = self.lat
        annotation.coordinate.longitude = self.lon
        self.mapView.addAnnotation(annotation)
    }
    
    private func cropToBounds(image: UIImage) -> UIImage {
        // adapted from https://stackoverflow.com/questions/32041420/cropping-image-with-swift-and-put-it-on-center-position
        // and https://web.archive.org/web/20150809132743/http://carl-thomas.name/crop-image-to-square/
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(contextSize.width)
        var cgheight: CGFloat = CGFloat(contextSize.height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "marker2"
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        return view
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return VirtualTouristModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PhotoCell
       
        let photoView = VirtualTouristModel.images[indexPath.row]
        
        if let photo = photoView.photo {
            
            let croppedPhoto = cropToBounds(image: photo)
            
            cell.backgroundColor = .white
            
            cell.imageView.image = croppedPhoto
        }
        
        return cell
    }

}
