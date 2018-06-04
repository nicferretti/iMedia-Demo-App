//
//  VenueImage.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 19/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import Alamofire
import AlamofireImage
import SwiftyJSON
import UIKit

class VenueImage {
    var id: String
    var urlPrefix: String
    var urlSuffix: String
    var url: String {
        return urlPrefix + "original" + urlSuffix
    }
    var width: Double
    var height: Double
    var aspectRatio: Double {
        return height / width
    }
    var image: UIImage?
    
    init(photoJSON: JSON) {
        id = photoJSON["id"].stringValue
        urlPrefix = photoJSON["prefix"].stringValue
        urlSuffix = photoJSON["suffix"].stringValue
        width = photoJSON["width"].doubleValue
        height = photoJSON["height"].doubleValue
    }
    
    func downloadThumbnail(completion: @escaping (_ thumbNail: UIImage?, _ error: Error?) -> ()) {
        let url = urlPrefix + "cap50" + urlSuffix
        Alamofire.request(url).responseData { (response) in
            guard let data = response.result.value else {
                let error = NSError(domain: "com.iMedia", code: 2, userInfo: [NSLocalizedDescriptionKey : "An error occurred downlaoding the thumbnail."])
                completion(nil, error)
                return
            }
            let thumbnail = UIImage(data: data)
            completion(thumbnail, nil)
        }
    }
    
    func downloadImage(completion: @escaping (_ completed: Bool, _ progress: Double) -> ()) {
        let url = urlPrefix + "original" + urlSuffix
        Alamofire.request(url).downloadProgress { (progress) in
            completion(false, progress.fractionCompleted)
        }.responseData { (response) in
            guard let data = response.result.value else {return}
            self.image = UIImage(data: data)
            completion(true, 1.0)
        }
    }
}
