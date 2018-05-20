//
//  ViewController.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 19/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import UIKit
import GoogleMaps
import SCLAlertView

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setUpLocationManager()
        setUpMapView()
    }

    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setUpMapView() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager error: ", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        let currentCoordinates = currentLocation.coordinate
        
        mapView.camera = GMSCameraPosition(target: currentCoordinates, zoom: 17, bearing: 0, viewingAngle: 0)
        
        //query for venues near users current location
        Venues.shared.findVenues(near: currentCoordinates) { (venues, error) in
            if let error = error {
                let errorAlert = SCLAlertView()
                errorAlert.showError("Uh Oh!", subTitle: error.localizedDescription, closeButtonTitle: "Ok")
            } else {
                guard let venues = venues else {return}
                self.mapView.clear()
                for venue in venues {
                    let marker = GMSMarker(position: venue.location.coordinates)
                    marker.userData = ["venue" : venue]
                    marker.map = self.mapView
                }
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let userData = marker.userData as? [String : Any] else {return false}
        guard let venue = userData["venue"] as? Venue else {return false}
        let venueImagesController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "venueImagesViewController") as! VenueImagesViewController
        venueImagesController.venue = venue
        self.present(venueImagesController, animated: true, completion: nil)
        return true
    }
}

