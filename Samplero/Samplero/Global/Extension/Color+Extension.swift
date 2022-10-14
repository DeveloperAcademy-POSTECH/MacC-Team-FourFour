//
//  Color+Extension.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/07.
//

import UIKit
extension UIColor {

//  에셋 컬러 사용 예시
    static let accent: UIColor = UIColor(hex: "2F2B2B")
    static let boxBackground: UIColor = .secondarySystemBackground
    static let primaryBlack: UIColor = .black
    static let secondaryGray: UIColor = .secondaryLabel

// 헥사코드 컬러 사용 예시
    static let addedButtonGray: UIColor = UIColor(hex: "F5F5F5")
    }


extension UIColor {
    static func load(name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            assert(false, "\(name) 컬러 로드 실패")
            return UIColor()
        }
        return color
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}
