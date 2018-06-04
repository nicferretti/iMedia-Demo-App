//
//  VenueImagesViewController.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 19/05/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import UIKit
import SCLAlertView
import SVProgressHUD

class VenueImagesViewController: UIViewController {
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var venue: Venue?
    
    let cellId = "imageCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let venue = venue else { return }
        setUpNavigationBar(venue)
        fetchImages(venue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    private func setUpNavigationBar(_ venue: Venue) {
        self.navigationBar.topItem?.titleView = setTitleView(title: venue.name, subtitle: "Photos")
        setUpDismissButton()
    }
    
    private func fetchImages(_ venue: Venue) {
        SVProgressHUD.show(withStatus: "Fetching photos...")
        venue.getImages { (success, error) in
            if success {
                SVProgressHUD.dismiss()
                if let _ = venue.images {
                    self.tableView.animateCellsFromBottom()
                    self.tableView.isHidden = false
                } else {
                    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                    let timeout = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 3.0, timeoutAction: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    let errorAlert = SCLAlertView(appearance: appearance)
                    errorAlert.showError("Uh Oh!", subTitle: "No photos available for this venue.", timeout: timeout)
                }
            } else {
                SVProgressHUD.dismiss()
                guard let error = error else {return}
                let errorAlert = SCLAlertView()
                errorAlert.showError("Error", subTitle: error.localizedDescription, closeButtonTitle: "Ok")
            }
        }
    }
    
    private func setTitleView(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-5, width:0, height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor(red: 28/255, green: 38/255, blue: 66/255, alpha: 1)
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.darkGray
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff > 0 {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = frame.integral
        } else {
            var frame = subtitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            subtitleLabel.frame = frame.integral
        }
        
        return titleView
    }
    
    private func setUpDismissButton() {
        let widthConstraint = dismissButton.widthAnchor.constraint(equalToConstant: 30)
        let heightConstraint = dismissButton.heightAnchor.constraint(equalToConstant: 30)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension VenueImagesViewController: UITableViewDataSource, UITableViewDelegate, ImageTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let venue = venue else {return 0}
        guard let images = venue.images else {return 0}
        return images.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let venue = venue else {return 0}
        guard let images = venue.images else {return 0}
        let imageViewWidth = UIScreen.main.bounds.width - 16
        if images[indexPath.row].image == nil {
            return 250
        } else {
            return (imageViewWidth * CGFloat(images[indexPath.row].aspectRatio)) + 8
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let venue = venue else {return UITableViewCell()}
        guard let venueImages = venue.images else {return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageTableViewCell
        cell.venueImage = venueImages[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let venue = venue else {return}
        guard let venueImages = venue.images else {return}
        let fullScreenVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullScreenImageViewController") as! FullScreenImageViewController
        fullScreenVC.venueImage = venueImages[indexPath.row]
        self.present(fullScreenVC, animated: true, completion: nil)
    }
    
    func completedDownloadForVenueImage(venueImage: VenueImage) {
        guard let venue = venue else {return}
        guard let venueImages = venue.images else {return}
        guard let index = venueImages.index(where: {$0 === venueImage}) else {return}
        let indexPathToReload = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPathToReload], with: .automatic)
    }
}
