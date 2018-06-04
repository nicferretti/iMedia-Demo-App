//
//  FullScreenImageViewController.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 20/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import UIKit
import Sensitive

class FullScreenImageViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageIdLabel: UILabel!
    @IBOutlet var imageUrlLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var imageBackgroundView: UIView!
    @IBOutlet var viewTopConstraint: NSLayoutConstraint!
    
    var venueImage: VenueImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
        addZoomToImageView()
        addPanToDismiss()
    }
    
    private func setUpView() {
        guard let venueImage = venueImage else {return}
        imageView.image = venueImage.image
        imageIdLabel.text = "Image ID: \(venueImage.id)"
        imageUrlLabel.text = "Image URL: \(venueImage.url)"
    }
    
    private func addZoomToImageView() {
        imageView.onPinch { (pinchGesture) in
            if pinchGesture.state == .changed {
                guard let imageView = pinchGesture.view else {return}
                
                let pinchCenterX = pinchGesture.location(in: imageView).x - imageView.bounds.midX
                let pinchCenterY = pinchGesture.location(in: imageView).y - imageView.bounds.midY
                let pinchCenter = CGPoint(x: pinchCenterX, y: pinchCenterY)
                
                let transform = imageView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                
                let currentScale = self.imageView.frame.size.width / self.imageView.bounds.size.width
                var newScale = currentScale * pinchGesture.scale
                
                if newScale < 1 {
                    newScale = 1
                    
                    let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                    self.imageView.transform = transform
                    pinchGesture.scale = 1
                } else {
                    imageView.transform = transform
                    pinchGesture.scale = 1
                }
            } else if pinchGesture.state == .ended {
                UIView.animate(withDuration: 0.35, animations: {
                    self.imageView.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    private func addPanToDismiss() {
        imageBackgroundView.onPan { (panGesture) in
            let offSet = panGesture.translation(in: self.view)
            let screenHeight = UIScreen.main.bounds.height
            
            if panGesture.state == .changed {
                guard offSet.y >= 0 else {return}
                self.viewTopConstraint.constant = offSet.y
                
                var opacity = Float(((screenHeight - offSet.y) / screenHeight))
                if opacity > 0.8 {
                    opacity = 0.8
                }
                self.backgroundView.layer.opacity = opacity
                
            } else if panGesture.state == .ended {
                if offSet.y >= screenHeight * 0.4 {
                    self.viewTopConstraint.constant = screenHeight
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                        self.backgroundView.layer.opacity = 0
                        self.view.layoutIfNeeded()
                    }, completion: { (completed) in
                        self.dismiss(animated: false, completion: nil)
                    })
                } else {
                    self.viewTopConstraint.constant = 0
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
            }
        }
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
