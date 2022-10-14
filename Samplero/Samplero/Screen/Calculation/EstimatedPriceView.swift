//
//  EstimatedPriceView.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/13.
//

import UIKit

class EstimatedPriceView: UIView {
    
    
    // MARK: - Properties
    
    var delegate: ShowModalDelegate?
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "셀프 시공 예상 가격"
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let showPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let estimatedPriceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let textButton: PaddedButton = {
        let button = PaddedButton(topInset: 4, bottomInset: 4, leftInset: 8, rightInset: 8)
        button.addTarget(self, action: #selector(tapButton(sender:)), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.tintColor = .white
        button.setTitle("변경", for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return button
    }()
    
    private let sizeAndQuantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        label.textColor = .white
        return label
    }()
    
    private let pricePerBlockLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        label.textColor = .white
        return label
    }()
    
    private let showQuantityAndPriceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .trailing
        return stackView
    }()
    
    
    // MARK: - Init
    
    init(estimatedPrice: Int, width: Int, height: Int, estimatedQuantity: Int, pricePerBlock: Int) {
        super.init(frame: .zero)
        changeEstimation(estimatedPrice: estimatedPrice, width: width, height: height, estimatedQuantity: estimatedQuantity, pricePerBlock: pricePerBlock)
        render()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Func
    
    private func render() {
        self.addSubview(estimatedPriceStackView)
        estimatedPriceStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        estimatedPriceStackView.addArrangedSubview(priceLabel)
        estimatedPriceStackView.addArrangedSubview(showPriceLabel)
        
        self.addSubview(textButton)
        textButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.snp.trailing).inset(20)
        }
        
        self.addSubview(showQuantityAndPriceStackView)
        showQuantityAndPriceStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(textButton.snp.leading).offset(-7)
        }
        showQuantityAndPriceStackView.addArrangedSubview(sizeAndQuantityLabel)
        showQuantityAndPriceStackView.addArrangedSubview(pricePerBlockLabel)

    }

    @objc func tapButton(sender: UIButton) {
        delegate?.buttonDidTapped()
    }
    
    func changeEstimation(estimatedPrice: Int, width: Int, height: Int, estimatedQuantity: Int, pricePerBlock: Int) {
        self.showPriceLabel.text = estimatedPrice == -1 ? "미정" : numberFormatter(number: estimatedPrice)
        self.sizeAndQuantityLabel.text = "\(width)x\(height)(cm), \(estimatedQuantity)장"
        self.pricePerBlockLabel.text = pricePerBlock == -1 ? "장당 가격 미정" : "장당 \(numberFormatter(number: pricePerBlock))원"
    }
    
    func numberFormatter(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: number))!
    }
}

protocol ShowModalDelegate {
    func buttonDidTapped()
}
