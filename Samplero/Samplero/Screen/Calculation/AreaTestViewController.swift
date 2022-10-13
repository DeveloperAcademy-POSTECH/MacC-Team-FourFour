//
//  AreaTestViewController.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/09.
//

import UIKit

import SnapKit

final class AreaTestViewController: BaseViewController {

    // MARK: - Properties
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "예상 가격"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let textButton: PaddedButton = {
        let button = PaddedButton(topInset: 7, bottomInset: 7, leftInset: 17, rightInset: 17)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.tintColor = .white
        button.setTitle("면적 입력하기", for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return button
    }()
    
    private let priceAndAreaStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .black
        stackView.alpha = 0.5
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLayoutSubviews() {
        textButton.layer.cornerRadius = textButton.bounds.height/2
    }
    
    override func render() {
        view.addSubview(priceAndAreaStackView)
  
        priceAndAreaStackView.addArrangedSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
        }
        
        priceAndAreaStackView.addArrangedSubview(textButton)
        textButton.snp.makeConstraints { make in
            make.trailing.equalTo(view).inset(20)
        }
        
        priceAndAreaStackView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(80)
        }
    }
    
    override func configUI() {
    }
    
    
    // MARK: - Func
    
    @objc func buttonDidTap() {
        let viewController = GetAreaViewController()
        viewController.preferredSheetSizing = .medium
        present(viewController, animated: true)
    }
}
