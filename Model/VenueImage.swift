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
    var url: String
    var width: Double
    var height: Double
    var aspectRatio: Double {
        return height / width
    }
    var image: UIImage?
    
    init(photoJSON: JSON) {
        id = photoJSON["id"].stringValue
        url = photoJSON["prefix"].stringValue + "original" + photoJSON["suffix"].stringValue
        width = photoJSON["width"].doubleValue
        height = photoJSON["height"].doubleValue
    }
    
    func downloadImage(completion: @escaping (_ completed: Bool, _ progress: Double) -> ()) {
        Alamofire.request(url).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            completion(false, progress.fractionCompleted)
        }.responseData { (response) in
            guard let data = response.result.value else {return}
            self.image = UIImage(data: data)
            completion(true, 1.0)
        }
    }
}
