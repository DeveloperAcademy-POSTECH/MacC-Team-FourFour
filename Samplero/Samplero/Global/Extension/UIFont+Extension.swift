//
//  UIFont+Extension.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/14.
//

import UIKit


extension UIFont {

    /// regularCaption1 - 12px
    static let regularCaption1 = UIFont.font(.caption1, weight: .regular)
    /// regularFootnote - 13px
    static let regularFootnote = UIFont.font(.footnote, weight: .regular)
    /// regularSubheadline - 15px
    static let regularSubheadline = UIFont.font(.subheadline, weight: .regular)
    /// regularCallout - 16px
    static let regularCallout = UIFont.font(.callout, weight: .regular)
    /// regularBody - 17px
    static let regularBody = UIFont.font(.body, weight: .regular)


    /// regularCaption1 - 12px
    static let boldCaption1 = UIFont.font(.caption1, weight: .bold)
    /// regularFootnote - 13px
    static let boldFootnote = UIFont.font(.footnote, weight: .bold)
    /// regularSubheadline - 15px
    static let boldSubheadline = UIFont.font(.subheadline, weight: .bold)
    /// regularCallout - 16px
    static let boldCallout = UIFont.font(.callout, weight: .bold)
    /// regularBody - 17px
    static let boldBody = UIFont.font(.body, weight: .bold)
}


extension UIFont {

    static func font(_ textStyle: TextStyle, weight: Weight) -> UIFont {
        return UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: textStyle).pointSize, weight: weight)
    }
}
