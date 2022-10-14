//
//  ToBeEstimatedPriceView.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/13.
//

import UIKit

class ToBeEstimatedPriceView: UIView {
    
    
    // MARK: - Properties
    
    var delegate: ShowModalDelegate?
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "예상 가격"
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    let textButton: PaddedButton = {
        let button = PaddedButton(topInset: 7, bottomInset: 7, leftInset: 17, rightInset: 17)
        button.addTarget(self, action: #selector(tapButton(sender:)), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.tintColor = .white
        button.setTitle("면적 입력하기", for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return button
    }()
    
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        render()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Func

    private func render() {
        self.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        self.addSubview(textButton)
        textButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }

    @objc func tapButton(sender: UIButton) {
        delegate?.buttonDidTapped()
    }
    
}
