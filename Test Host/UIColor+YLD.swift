//
//  UIColor+YLD.swift
//  Test Host
//
//  Created by Sven Herzberg on 22.10.19.
//

import UIKit

extension UIColor {
    
    @available(iOS, deprecated: 13, message: "Use UIColor.secondaryLabel directly.")
    static var yld_secondaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }
        
        // Value copied from iOS 13 using default settings.
        return UIColor(red: 0.235294, green: 0.235294, blue: 0.262745, alpha: 0.6)
    }
    
}
