//
//  CustomGetSizeView.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/11.
//

import UIKit

class CustomGetSizeView: UIView {
    
    // MARK: - Properties
    
    private let textField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "0"
        textfield.keyboardType = .numberPad
        textfield.textAlignment = .right
        return textfield
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private let cmLabel: UILabel = {
        let label = UILabel()
        label.text = "cm"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(hex: "8A8A8E")
        return label
    }()
    
    
    // MARK: - Init

    init(labelText: String) {
        super.init(frame: .zero)
        sizeLabel.text = labelText
        render()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Func
    
    private func render() {
        self.addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        self.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(52)
            make.width.equalTo(100)
            make.centerY.equalToSuperview()
        }
        self.addSubview(cmLabel)
        cmLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }
}
