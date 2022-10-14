//
//  SampleDetailView.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/08.
//

import UIKit

private enum Size {
    static let defaultOffset = 20.0
    static let horizontalLineHeight = 1
    static let horizontalLineTopOffset = 12
    static let vStackViewTopOffset = 12
    static let vStackViewSpacing = 8.0
    static let nameStackViewTopOffset = 2
    static let materialStackViewWidth = 276.0
    static let makerLabelTopOffset = 12.0
    static let samplePriceStackViewSpacing = 24.0
}


final class SampleDetailView: UIView {


    // MARK: - Properties

    private let makerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .regularCaption1
        label.textColor = .secondaryGray
        return label
    }()
    private let sampleNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .boldBody
        label.textColor = .black
        return label
    }()

    private let samplePriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .regularSubheadline
        label.text = "샘플가격"
        label.textColor = .secondaryGray
        return label
    }()

    private let samplePriceValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .boldSubheadline
        label.textColor = .primaryBlack
        return label
    }()

    private let samplePriceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = Size.samplePriceStackViewSpacing
        return stackView
    }()

    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private let horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBlack
        view.layer.opacity = 0.5
        return view
    }()

    private let materialStackView = EstimateCommonStackView(detailName: "소재")

    private let thicknessStackView = EstimateCommonStackView(detailName: "두께")

    private let sizeStackView = EstimateCommonStackView(detailName: "크기")

    private let firstHorizontalView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private let secondHorizontalView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = Size.vStackViewSpacing
        return stackView
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
        nameStackView.addArrangedSubview(sampleNameLabel)
        nameStackView.addArrangedSubview(UIView())
        nameStackView.addArrangedSubview(samplePriceStackView)
        samplePriceStackView.addArrangedSubview(samplePriceLabel)
        samplePriceStackView.addArrangedSubview(samplePriceValueLabel)

        self.addSubview(makerLabel)
        makerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.makerLabelTopOffset)
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
        }
        self.addSubview(nameStackView)
        nameStackView.snp.makeConstraints { make in
            make.top.equalTo(makerLabel.snp.bottom).offset(Size.nameStackViewTopOffset)
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
        }

        self.addSubview(horizontalLine)
        horizontalLine.snp.makeConstraints { make in
            make.top.equalTo(nameStackView.snp.bottom).offset(Size.horizontalLineTopOffset)
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
            make.height.equalTo(Size.horizontalLineHeight)
        }

        self.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(horizontalLine).offset(Size.vStackViewTopOffset)
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
        }

        verticalStackView.addArrangedSubview(firstHorizontalView)
        verticalStackView.addArrangedSubview(secondHorizontalView)

        firstHorizontalView.addArrangedSubview(materialStackView)
        materialStackView.setValueLabelWidth(Size.materialStackViewWidth)
        firstHorizontalView.addArrangedSubview(UIView())

       // firstHorizontalView.addArrangedSubview(thicknessStackView)
        firstHorizontalView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        secondHorizontalView.addArrangedSubview(sizeStackView)
        secondHorizontalView.addArrangedSubview(thicknessStackView)
        secondHorizontalView.addArrangedSubview(UIView())
        secondHorizontalView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

    }

     func configure(with sample: Sample) {
         sampleNameLabel.text = sample.matName
         materialStackView.setValueLabel(with: sample.material)
         thicknessStackView.setValueLabel(with: "\(sample.thickness.description)cm")
         sizeStackView.setValueLabel(with: sample.size.toString)
         makerLabel.text = sample.maker
         samplePriceValueLabel.text = (sample.samplePrice == .zero ? "무료" : "\(sample.samplePrice.description)원")
    }


}
