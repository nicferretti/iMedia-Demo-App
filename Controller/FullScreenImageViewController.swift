//
//  FullScreenImageViewController.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 20/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageIdLabel: UILabel!
    @IBOutlet var imageUrlLabel: UILabel!
    
    var venueImage: VenueImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
    }
    
    private func setUpView() {
        guard let venueImage = venueImage else {return}
        imageView.image = venueImage.image
        imageIdLabel.text = "Image ID: \(venueImage.id)"
        imageUrlLabel.text = "Image URL: \(venueImage.url)"
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
