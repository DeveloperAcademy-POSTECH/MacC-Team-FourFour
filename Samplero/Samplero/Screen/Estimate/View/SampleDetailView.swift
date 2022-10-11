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
    static let horizontalLineTopOffset = 17
    static let vStackViewTopOffset = 10
    static let vStackViewSpacing = 8.0
    static let nameStackViewTopOffset = 27
}


final class SampleDetailView: UIView {


    // MARK: - Properties


    private let sampleNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let matPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .right
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()


    private let materialStackView = EstimateCommonStackView(detailName: "소재")

    private let thicknessStackView = EstimateCommonStackView(detailName: "두께")

    private let sizeStackView = EstimateCommonStackView(detailName: "크기")

    private let makerStackView = EstimateCommonStackView(detailName: "제조사")

    private let firstHorizontalView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = Size.defaultOffset
        return stackView
    }()

    private let secondHorizontalView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = Size.defaultOffset
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
        nameStackView.addArrangedSubview(matPriceLabel)

        self.addSubview(nameStackView)
        nameStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.nameStackViewTopOffset)
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
        firstHorizontalView.addArrangedSubview(thicknessStackView)
        firstHorizontalView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        secondHorizontalView.addArrangedSubview(sizeStackView)
        secondHorizontalView.addArrangedSubview(makerStackView)
        secondHorizontalView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

    }

     func configure(with sample: Sample) {
        sampleNameLabel.text = sample.matName
        matPriceLabel.text = "장당 \(sample.matPrice)원"
        materialStackView.setValueLabel(with: sample.material)
         thicknessStackView.setValueLabel(with: "\(sample.thickness.description)cm")
         sizeStackView.setValueLabel(with: sample.size.toString)
        makerStackView.setValueLabel(with: sample.maker)
    }


}