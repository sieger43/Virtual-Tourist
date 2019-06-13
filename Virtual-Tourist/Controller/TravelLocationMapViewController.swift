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
import CoreData

class TravelLocationMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tapPinsToDeleteButton: UIButton!
    
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var inEditMode = false;
    
    var pins : [Pin] = []
    
    var dataController:DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.checkAction))
        mapView.addGestureRecognizer(tap)

        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest();
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            refreshMapPins()
        }
        
        if let button = tapPinsToDeleteButton {
            button.isHidden = true;
        }
    }

    @IBAction func editPin(_ sender: Any) {
        
        if let constraint = mapViewBottomConstraint,
            let button = tapPinsToDeleteButton,
            let edit = editButton {
            
            if inEditMode {
                button.isHidden = true
                edit.title = "Edit"
                constraint.constant += button.frame.height;
                inEditMode = false
                
            } else {
                button.isHidden = false
                edit.title = "Done"
                constraint.constant -= button.frame.height;
                inEditMode = true
            }

        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
    }
    
    func addPin(click_latitude: Double, click_longitude: Double) {
        
        let mapPin = Pin(context: dataController.viewContext)
        mapPin.latitude = click_latitude;
        mapPin.longitude = click_longitude;
        try? dataController.viewContext.save()
        pins.append(mapPin)
    }
    
    func deletePin(click_latitude: Double, click_longitude: Double) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let latPredicate = NSPredicate(format: "latitude = %@", argumentArray: [click_latitude])
        let lonPredicate = NSPredicate(format: "longitude = %@", argumentArray: [click_longitude])
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [latPredicate, lonPredicate])
        
        fetch.predicate = andPredicate

        do {
            
            let result = try dataController.viewContext.fetch(fetch)
            
            if result.count == 1 {
                let p : Pin = result[0] as! Pin
                dataController.viewContext.delete(p)
                try? dataController.viewContext.save()
            }
        } catch {
            let _ = "deletePin() Failed"
        }
        
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
        
        if inEditMode {
            
            if let annotation = view.annotation {
                deletePin(click_latitude: annotation.coordinate.latitude,
                      click_longitude: annotation.coordinate.longitude)
                
                self.mapView.removeAnnotation(annotation)
                refreshMapPins()
            }
            
        } else {
        
            let backItem = UIBarButtonItem()
            backItem.title = "OK"
            navigationItem.backBarButtonItem = backItem
        
            if let annotation = view.annotation {

                photoViewController.lat = annotation.coordinate.latitude;
                photoViewController.lon = annotation.coordinate.longitude;
                photoViewController.dataController = self.dataController
                
                DispatchQueue.main.async(execute: {

                    if let annotation = view.annotation {
                        // the selection of the pin doesn't automatically clear and
                        // prevents the pin from being selected twice in a row; deselect
                        // all the pins here
                        mapView.deselectAnnotation(annotation, animated: false)
                    }
                    
                    self.navigationController!.pushViewController(photoViewController, animated: true)
                })
            }
        }
    }

    @objc func checkAction(_ gestureRecognizer: UILongPressGestureRecognizer) {

        if gestureRecognizer.state == .began && !inEditMode {
            
            let touchLocation = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let lat = locationCoordinate.latitude
            let lon = locationCoordinate.longitude

            addPin(click_latitude: lat, click_longitude: lon)
            
            DispatchQueue.main.async(execute: {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                self.mapView.addAnnotation(annotation)
            })
        }
    }
    
    func refreshMapPins() {
        
        DispatchQueue.main.async(execute: {
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            for pin in self.pins {
                let lat = pin.latitude
                let lon = pin.longitude
                    
                let mapAnnotation = MKPointAnnotation()
                
                mapAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                self.mapView.addAnnotation(mapAnnotation)
            }
        })
        
    }
}
