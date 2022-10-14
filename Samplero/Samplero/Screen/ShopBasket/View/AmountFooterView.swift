//
//  AmountFooterView.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/12.
//

import UIKit


class AmountFooterView: UICollectionReusableView {


    // MARK: - Properties

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
        stackView.spacing = 12
        return stackView
    }()

    private let divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .separator
        return divider
    }()
    private let topSapcingView = UIView()
    private let totalPriceView = AmountStackView(detailName: "합계")
    private let deliveryFeeView = AmountStackView(detailName: "배송비")
    private let totalAmountView = AmountStackView(detailName: "총 결제예정 금액")

    private let deliveryFee = 0
    // MARK: - Init


    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        configUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Func


    private func render() {
        self.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))

        }
        verticalStackView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
//
        verticalStackView.addArrangedSubview(topSapcingView)
        topSapcingView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(24)
        }
        verticalStackView.addArrangedSubview(totalPriceView)
        totalPriceView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
        verticalStackView.addArrangedSubview(deliveryFeeView)
        deliveryFeeView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
        verticalStackView.addArrangedSubview(totalAmountView)
        totalAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
    }

    private func configUI() {
        totalPriceView.setValueLabel(with: "0원")
        deliveryFeeView.setValueLabel(with: "0원")
        totalAmountView.setValueLabel(with: "0원")

    }

    func configure(with totalPrice: Int) {
        totalPriceView.setValueLabel(with: "\(totalPrice)원")
        deliveryFeeView.setValueLabel(with: "\(deliveryFee)원")
        totalAmountView.setValueLabel(with: "\(totalPrice + deliveryFee)원")
    }
}


