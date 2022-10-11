//
//  GetAreaViewController.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/09.
//
import UIKit

final class GetAreaViewController: BottomSheetController {
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        title.text = "시공 면적 입력"
        title.textAlignment = .center
        return title
    }()
    
    private let widthTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "0"
        textfield.keyboardType = .numberPad
        textfield.textAlignment = .right
        return textfield
    }()
    
    private let heightTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "0"
        textfield.keyboardType = .numberPad
        textfield.textAlignment = .right
        return textfield
    }()
    
    private let widthLabel: UILabel = {
        let label = UILabel()
        label.text = "가로"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    let getWidthView: UIView = {
        let view = UIView()
        let cmLabel = UILabel()
        cmLabel.text = "cm"
        cmLabel.font = .systemFont(ofSize: 12, weight: .regular)
        cmLabel.textColor = UIColor(hex: "8A8A8E")
        view.addSubview(cmLabel)
        
        cmLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.text = "세로"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    let getHeightView: UIView = {
        let view = UIView()
        let cmLabel = UILabel()
        cmLabel.text = "cm"
        cmLabel.font = .systemFont(ofSize: 12, weight: .regular)
        cmLabel.textColor = UIColor(hex: "8A8A8E")
        view.addSubview(cmLabel)

        cmLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        return view
    }()
    
    let separator = UIView()
    
    let textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 50
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = CGColor(gray: 0, alpha: 1)
        stackView.layer.cornerRadius = 6
        return stackView
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .black
        button.backgroundColor = UIColor(hex: "F2F2F7")
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        return button
    }()
    
    override func render() {
        self.hideKeyboardWhenTappedAround()
        
        getWidthView.addSubview(widthLabel)
        getWidthView.addSubview(widthTextField)
        getHeightView.addSubview(heightLabel)
        getHeightView.addSubview(heightTextField)
        textFieldStackView.addArrangedSubview(getWidthView)
        textFieldStackView.addArrangedSubview(separator)
        textFieldStackView.addArrangedSubview(getHeightView)
        view.addSubview(titleLabel)
        view.addSubview(textFieldStackView)
        view.addSubview(saveButton)
        
        view.backgroundColor = .systemBackground
    }
    
    override func configUI() {
        widthLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        widthTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(52)
            make.width.equalTo(100)
            make.centerY.equalToSuperview()
        }
        heightLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        heightTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(52)
            make.width.equalTo(100)
            make.centerY.equalToSuperview()
        }
        
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        getWidthView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(textFieldStackView)
            make.height.equalTo(48)
        }
        separator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(getWidthView.snp.bottom)
            make.height.equalTo(1)
        }
        getHeightView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(view).offset(17)
        }
        textFieldStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
        }
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(17)
            make.top.equalTo(textFieldStackView.snp.bottom).offset(26)
        }
    }
    
    @objc func buttonDidTap() {
        dismiss(animated: true)
    }
}
