//
//  UIBarButtonItem+YLD.swift
//  Test Host
//
//  Created by Sven Herzberg on 23.10.19.
//

import UIKit

extension UIBarButtonItem {
    
    static func location(target: Any?, action: Selector?) -> UIBarButtonItem {
        if #available(iOS 13, *) {
            let image = UIImage(systemName: "location.fill")
            return UIBarButtonItem(image: image, landscapeImagePhone: image,
                                   style: .plain,
                                   target: target,
                                   action: action)
        }
        
        return UIBarButtonItem(barButtonSystemItem: .yld_location, target: target, action: action)
    }
    
}

extension UIBarButtonItem.SystemItem {
    
    @available(iOS, introduced: 12, obsoleted: 13)
    static var yld_location: UIBarButtonItem.SystemItem {
        UIBarButtonItem.SystemItem(rawValue: 100)!
    }
    
}
