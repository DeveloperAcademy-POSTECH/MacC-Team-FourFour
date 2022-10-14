//
//  PaddedButton.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/13.
//

import UIKit

import SnapKit

class PaddedButton: UIButton {

    
    // MARK: - Properties
    
    var topInset: CGFloat
    var bottomInset: CGFloat
    var leftInset: CGFloat
    var rightInset: CGFloat
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    
    // MARK: - Init
    
    init(topInset: CGFloat, bottomInset: CGFloat, leftInset: CGFloat, rightInset: CGFloat) {
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.leftInset = leftInset
        self.rightInset = rightInset
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

