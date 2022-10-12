//
//  CustomCheckbox.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/12.
//

import UIKit

class CustomCheckbox: UIButton {
    // Images
    let checkedImage = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal)
    let uncheckedImage = UIImage()
    
    
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
                self.backgroundColor = UIColor.accent
            } else {
                self.setImage(uncheckedImage, for: .normal)
                self.backgroundColor = .systemBackground
            }
        }
    }
    
    init(isChecked: Bool) {
        super.init(frame: .zero)
        self.isChecked = isChecked
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.boxBackground.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
