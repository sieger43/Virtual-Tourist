//
//  ViewController.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/22/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class TravelLocationMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.checkAction))
        mapView.addGestureRecognizer(tap)
    }

    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
    }
}

extension TravelLocationMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let identifier = "marker"
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
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView) {
        let photoViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        navigationItem.backBarButtonItem = backItem
        
        if let annotation = view.annotation {
            
            photoViewController.lat = annotation.coordinate.latitude;
            photoViewController.lon = annotation.coordinate.longitude;
            
            self.navigationController!.pushViewController(photoViewController, animated: true)
        }
    }

    @objc func checkAction(_ gestureRecognizer: UILongPressGestureRecognizer) {

        if gestureRecognizer.state == .began {
            
            let touchLocation = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let click_latitude = locationCoordinate.latitude
            let click_longitude = locationCoordinate.longitude

            DispatchQueue.main.async(execute: {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: click_latitude, longitude: click_longitude)
                self.mapView.addAnnotation(annotation)
            })
        }
    }
}
