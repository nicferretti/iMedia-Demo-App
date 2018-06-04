//
//  Venues.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 19/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import Alamofire
import CoreLocation
import SwiftyJSON

class Venues {
    
    static var shared = Venues()
    
    func findVenues(near location: CLLocationCoordinate2D, completion: @escaping (_ venues: [Venue]?, _ error: Error?) -> ()) {
        let baseUrl = "https://api.foursquare.com/v2/venues/search"
        let parameters: Parameters = [
            "client_id" : Constants.Foursquare.clientId,
            "client_secret" : Constants.Foursquare.clientSecret,
            "ll" : "\(location.latitude),\(location.longitude)",
            "v": "20180519",
            "limit": 2
        ]
        
        Alamofire.request(baseUrl, method: .get, parameters: parameters).responseJSON { (urlResponse) in
            switch urlResponse.result {
            case .success:
                if let data = urlResponse.data {
                    let json = JSON(data: data)
                    print(json)
                    guard let response = json["response"].dictionary else {return}
                    if let venuesJSON = response["venues"]?.array {
                        var venues = [Venue]()
                        for venueJSON in venuesJSON {
                            let newVenue = Venue(venueJSON: venueJSON)
                            venues.append(newVenue)
                        }
                        completion(venues, nil)
                    } else {
                        let error = NSError(domain: "com.iMedia", code: 2, userInfo: [NSLocalizedDescriptionKey : "No venues found near you."])
                        completion(nil, error)
                    }
                } else {
                    //an error occurred and no data was received
                    var error = NSError()
                    //check network connection
                    if Reachability.isConnectedToNetwork() {
                        if let err = urlResponse.error {
                            error = NSError(domain: "com.iMedia", code: 1, userInfo: [NSLocalizedDescriptionKey : err.localizedDescription])
                        } else {
                            error = NSError(domain: "com.iMedia", code: 2, userInfo: [NSLocalizedDescriptionKey : "Unknown error occurred."])
                        }
                    } else {
                        error = NSError(domain: "com.iMedia", code: 2, userInfo: [NSLocalizedDescriptionKey : "There seems to be a problem with your connection."])
                    }
                    completion(nil, error)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
