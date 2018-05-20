//
//  Location.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 19/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import CoreLocation
import SwiftyJSON

class Location {
    var address: String
    var coordinates: CLLocationCoordinate2D
    var city: String
    var state: String
    var country: String
    
    init(locationJSON: JSON) {
        address = locationJSON["address"].stringValue
        let latitude = locationJSON["lat"].doubleValue
        let longitude = locationJSON["lng"].doubleValue
        coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        city = locationJSON["city"].stringValue
        state = locationJSON["state"].stringValue
        country = locationJSON["country"].stringValue
    }
}
