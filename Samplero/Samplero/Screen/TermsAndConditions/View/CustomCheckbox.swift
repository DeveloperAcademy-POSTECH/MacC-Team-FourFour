//
//  CustomCheckbox.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/12.
//

import UIKit

class CustomCheckbox: UIButton {
    
    // MARK: - Properties
    
    let checkedImage = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal)
    let uncheckedImage = UIImage()
    
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.setImage(checkedImage, for: .normal)
                self.backgroundColor = UIColor.accent
            } else {
                self.setImage(uncheckedImage, for: .normal)
                self.backgroundColor = .systemBackground
            }
        }
    }
    
    // MARK: - Init
    
    init(isChecked: Bool) {
        super.init(frame: .zero)
        self.isChecked = isChecked
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Func

    func configUI() {
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.boxBackground.cgColor
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            self.isChecked.toggle()
        }
    }
}
