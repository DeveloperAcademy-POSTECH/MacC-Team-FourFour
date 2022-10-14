//
//  CommonStackView.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import UIKit

private enum Size {
    static let valueLabelWidth = 101
}
final class EstimateCommonStackView: UIStackView {


    // MARK: - Properties


    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .regularSubheadline
        label.textColor = .secondaryGray
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .regularSubheadline
        label.textColor = .black
        return label
    }()


    // MARK: - Init


    init(detailName: String) {
        super.init(frame: .zero)
        nameLabel.text = detailName
        self.axis = .horizontal
        self.alignment = .leading
        self.distribution = .fill
        self.spacing = 24
        render()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Func


    private func render() {
        self.addArrangedSubview(nameLabel)
        self.addArrangedSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.width.equalTo(Size.valueLabelWidth)
        }
    }

    func setValueLabel(with value: String) {
        valueLabel.text = value
    }

    func setValueLabelWidth(_ width: CGFloat) {
        valueLabel.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }

}

