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
    var thumbnail: UIImage?
    var images: [VenueImage]?
    
    init(venueJSON: JSON) {
        id = venueJSON["id"].stringValue
        name = venueJSON["name"].stringValue
        let locationJSON = venueJSON["location"]
        location = Location(locationJSON: locationJSON)
    }
    
    func getThumbnail(completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        guard thumbnail == nil else {
            completion(true, nil)
            return
        }
        
        let url = "https://api.foursquare.com/v2/venues/\(id)/photos"
        let parameters: Parameters = [
            "client_id" : Constants.Foursquare.clientId,
            "client_secret" : Constants.Foursquare.clientSecret,
            "v": "20180519",
            "limit": 1
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
                    guard let firstPhoto = photoItems.first else {
                        completion(true, nil)
                        return
                    }
                    
                    let venueThumbnail = VenueImage(photoJSON: firstPhoto)
                    venueThumbnail.downloadThumbnail(completion: { (thumbnail, error) in
                        if let error = error {
                            completion(false, error)
                        } else {
                            guard let thumbnail = thumbnail else {return}
                            self.thumbnail = thumbnail
                            completion(true, nil)
                        }
                    })
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
    
    func getImages(completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        let url = "https://api.foursquare.com/v2/venues/\(id)/photos"
        let parameters: Parameters = [
            "client_id" : Constants.Foursquare.clientId,
            "client_secret" : Constants.Foursquare.clientSecret,
            "v": "20180519"
        ]
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (urlResponse) in
            switch urlResponse.result {
            case .success:
                if let data = urlResponse.data {
                    let json = JSON(data: data)
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
