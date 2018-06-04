//
//  Extentions.swift
//  iMedia Demo App
//
//  Created by Nicholas Ferretti on 04/06/2018.
//  Copyright © 2018 NFerretti. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexCode: String) {
        let scanner = Scanner(string: hexCode)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension UITableView {
    func reloadData(with animation: UITableViewRowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
    
    func animateCellsFromBottom() {
        self.reloadData()
        let cells = self.visibleCells
        let tableHeight: CGFloat = self.bounds.size.height
        
        //loop through all the visible cells and move them to the bottom of the screen
        for cell in cells {
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        //loop through all the cells that have now been moved to the bottom of the screen and return them to their original positions
        var index = 0.0
        for cell in cells {
            UIView.animate(withDuration: 0.60, delay: 0.1 * index, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                cell.alpha = 1
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            index += 1.0
        }
    }
}
