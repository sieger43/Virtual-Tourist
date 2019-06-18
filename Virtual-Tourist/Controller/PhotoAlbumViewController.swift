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

class AlbumPhoto
{
    init(photo:UIImage?, index:Int32, photoSource:Photo?)
    {
        self.photo = photo
        self.index = index
        self.photoSource = photoSource
    }
    
    convenience init(photo:UIImage?, index: Int32) {
        self.init(photo: photo, index: index, photoSource: nil)
    }
    
    convenience init() {
        self.init(photo: nil, index: -1, photoSource: nil)
    }
    
    var photo:UIImage?
    var index:Int32
    var photoSource:Photo?
}

class PhotoAlbum {
    
    static var images = [AlbumPhoto]()
    
}

class PhotoAlbumViewController: UIViewController {
    
    private let reuseIdentifier = "FlickrCell"

    var activePin:Pin?
    
    var dataController:DataController!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func doButtonTask(_ sender: Any) {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            
            if let title = newCollectionButton.currentTitle {
                if title == "Remove Selected Pictures" {
                    
                    let items = selectedItems.map { $0.item }.sorted().reversed()
                    
                    for item in items {
                        let photoToDelete = PhotoAlbum.images[item].photoSource
                        if let ptd = photoToDelete {
                            dataController.viewContext.delete(ptd)
                            PhotoAlbum.images.remove(at: item)
                            
                        }
                    }
                    try? self.dataController.viewContext.save()
                    
                    refreshPhotoList(forceRefresh: true)
                    
                    newCollectionButton.setTitle("New Collection", for: .normal)
                    
                } else if title == "New Collection" {

                    var index : Int32 = 0
                    
                    for photoToDelete in PhotoAlbum.images {
                        if let photoSource = photoToDelete.photoSource {
                            dataController.viewContext.delete(photoSource)
                            photoToDelete.photo = UIImage(named: "busyCell")
                            photoToDelete.index = index
                            index = index + 1
                        }
                    }
                    try? self.dataController.viewContext.save()

                    self.collectionView?.reloadData()
                    
                    refreshPhotoList(forceRefresh: true)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PhotoAlbum.images.removeAll()

        for i: Int32 in 1...21 {
            PhotoAlbum.images.append(AlbumPhoto(photo: UIImage(named: "busyCell" ), index: i))
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        
        refreshPhotoList(forceRefresh: false)
    }

    func refreshPhotoList(forceRefresh : Bool) {
 
        var haveCachedPhotos = false;
        
        self.centerMapOnLocation()
        
        if let mapPin = activePin, let theSet = mapPin.photos {
            let numPhotos = theSet.count
            if numPhotos == 0 {
                haveCachedPhotos = false
            } else {
                PhotoAlbum.images.removeAll()
                
                for case let photo as Photo in theSet  {
                    if let imageData = photo.imageData, let image = UIImage(data: imageData) {
                        PhotoAlbum.images.append(AlbumPhoto(photo: image, index: photo.index, photoSource: photo))
                    }
                }
                
                PhotoAlbum.images.sort(by: { $0.index > $1.index })
                
                haveCachedPhotos = true
                
                self.collectionView?.reloadData()
            }
        }
        
        if let mapPin = activePin, !haveCachedPhotos {

           FlickrClient.getPhotoList(lat: mapPin.latitude, lon: mapPin.longitude){ success, error, response in
                if success {

                    var index: Int32 = 0;
                    
                    if let thedata = response?.photos.photo {
                        
                        DispatchQueue.global().async(execute: {
                            PhotoAlbum.images.removeAll()

                            for photoRecord in thedata {
                                if let unwrapped_URL = URL(string: photoRecord.url_s){
                                    do {
                                        let imageData = try Data(contentsOf: unwrapped_URL)
                                        if let image = UIImage(data: imageData) {
                                            PhotoAlbum.images.append(AlbumPhoto(photo: image, index: index))
                                            index = index  + 1
                                            DispatchQueue.main.async(execute: {
                                                PhotoAlbum.images.sort(by: { $0.index > $1.index })
                                                self.collectionView?.reloadData()
                                            })
                                        }
                                    } catch {
                                        // empty on purpose
                                    }
                                }
                            }
                            
                            if !haveCachedPhotos {

                                    for photoView in PhotoAlbum.images {
                                        if let pic = photoView.photo  {
                                            let d = pic.pngData()
                                            let photo = Photo(context: self.dataController.viewContext)
                                            photo.imageData = d
                                            photo.index = photoView.index
                                            photoView.photoSource = photo
                                            mapPin.addToPhotos(photo)
                                        }
                                    }
                                    try? self.dataController.viewContext.save()
                            }
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
        
        if let mapPin = activePin {
        
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: mapPin.latitude, longitude: mapPin.longitude),
                                            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))

            self.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = mapPin.latitude
            annotation.coordinate.longitude = mapPin.longitude
            self.mapView.addAnnotation(annotation)
        }
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

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return PhotoAlbum.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PhotoCell
       
        let photoView = PhotoAlbum.images[indexPath.row]
        
        if let photo = photoView.photo {
            
            let croppedPhoto = cropToBounds(image: photo)
            
            cell.backgroundColor = .white
            
            cell.imageView.image = croppedPhoto
        }
        
        return cell
    }
    
    func updateButtonTitle(collectionView: UICollectionView) {
        if let button = self.newCollectionButton, let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.count > 0 {
                button.setTitle("Remove Selected Pictures", for: .normal)
            } else {
                button.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        selectedCell.alpha = 0.5
        
        updateButtonTitle(collectionView: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        selectedCell.alpha = 1.0

        updateButtonTitle(collectionView: collectionView)
    }
}
