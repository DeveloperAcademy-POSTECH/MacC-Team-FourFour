//
//  imageLiteral.swift
//  Gajeongtongsin
//
//  Created by DaeSeong on 2022/07/16.
//

import Foundation
import UIKit

enum ImageLiteral {
    static var sampleRoom: UIImage { .load(named: "SampleRoom")}
    static var shoppingBag: UIImage { .load(named: "ShoppingBag")}
}

extension UIImage {
    static func load(named imageName: String) -> UIImage {
        guard let image = UIImage(named: imageName) else {
            return UIImage()
        }
        image.accessibilityIdentifier = imageName
        return image
    }
    static func load(systemName: String) -> UIImage {
        guard let image = UIImage(systemName: systemName, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = systemName
        return image
    }
    
}
