//
//  Places.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 19/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import Alamofire
import CoreLocation
import SwiftyJSON

class Venue {
    var id: String
    var name: String
    var location: Location
    var images: [VenueImage]?
    
    init(venueJSON: JSON) {
        id = venueJSON["id"].stringValue
        name = venueJSON["name"].stringValue
        let locationJSON = venueJSON["location"]
        location = Location(locationJSON: locationJSON)
    }
    
    func getImages(completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        let url = "https://api.foursquare.com/v2/venues/\(id)/photos"
        let parameters: Parameters = [
            "client_id" : "MOJU2CY2DK41GZJKQVRM1ASCW3JBETAYNBBGY0OQ0ZBREQYL",
            "client_secret" : "5DROCZ11RBGDTULWFDIZNP2I0QOL5NUIJWFQD3BRZJGZBEET",
            "v": "20180519"
        ]
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (urlResponse) in
            switch urlResponse.result {
            case .success:
                if let data = urlResponse.data {
                    let json = JSON(data: data)
                    print(json)
                    guard let response = json["response"].dictionary else {return}
                    guard let photos = response["photos"]?.dictionary else {return}
                    guard let photoItems = photos["items"]?.arrayValue else {return}
                    guard photoItems.count > 0 else {
                        completion(true, nil)
                        return
                    }
                    
                    var venueImages = [VenueImage]()
                    for photo in photoItems {
                        let newImage = VenueImage(photoJSON: photo)
                        venueImages.append(newImage)
                    }
                    self.images = venueImages
                    completion(true, nil)
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
                    completion(false, error)
                }
            case .failure(let error):
                completion(false, error)
            }
        }
    }
}
