//
//  AmountStackView.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/12.
//

import UIKit

final class AmountStackView: UIStackView {


    // MARK: - Properties


    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryGray
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .right
        label.font = .systemFont(ofSize: 15)
        label.textColor = .primaryBlack
        return label
    }()


    // MARK: - Init


    init(detailName: String) {
        super.init(frame: .zero)
        nameLabel.text = detailName
        self.axis = .horizontal
        self.alignment = .leading
        self.distribution = .fill
        render()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Func


    private func render() {
        self.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
        }
        self.addArrangedSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
    }

    func setValueLabel(with value: String) {
        valueLabel.text = value
    }

}
