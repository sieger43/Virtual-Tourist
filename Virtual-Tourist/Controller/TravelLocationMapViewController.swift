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
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.checkAction))
        mapView.addGestureRecognizer(tap)
    }

    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
    }
}

extension TravelLocationMapViewController: MKMapViewDelegate {

    @objc func checkAction(sender : UITapGestureRecognizer) {

        print("click")

//        if self.mapView.selectedAnnotations.count > 0 {
//
//
//            let annotation = self.mapView.selectedAnnotations[0]
//
//            if let rawstring = annotation.subtitle, let urlstring = rawstring,
//                let url = URL(string: urlstring) {
//                UIApplication.shared.open(url, options: [:])
//            }
//        }
    }
}
