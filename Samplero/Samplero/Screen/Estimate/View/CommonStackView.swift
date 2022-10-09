//
//  CommonStackView.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import UIKit


class CommonStackView: UIStackView {


    // MARK: - Properties


    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray2
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()


    // MARK: - Init


    init(detailName: String, detailValue: String) {
        super.init(frame: .zero)
        nameLabel.text = detailName
        valueLabel.text = detailValue
        self.axis = .horizontal
        self.alignment = .leading
        self.distribution = .fillEqually
        render()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Func


    private func render() {
        self.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        self.addArrangedSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }

    func setValueLabel(with value: String) {
        valueLabel.text = value
    }

}
