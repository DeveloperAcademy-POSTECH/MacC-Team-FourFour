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


class SampleDetailView: UIView {


    // MARK: - Properties


    private let sampleNameLabel : UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "화이트마블"
        label.textColor = .black
        return label
    }()

    private let matPriceLabel : UILabel = {
        let label = UILabel()
        label.textAlignment =  .right
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "장당 12,000원"
        label.textColor = .black
        return label
    }()

    private let nameStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let horizontalLine : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()


    private let materialStackView = CommonStackView(
        detailName: "소재", detailValue: "TPU")

    private let thicknessStackView = CommonStackView(
        detailName: "두께", detailValue: "4cm")

    private let sizeStackView = CommonStackView(
        detailName: "크기", detailValue: "120x120")

    private let makerStackView = CommonStackView(
        detailName: "제조사", detailValue: "봄봄매트")

    private let h1StackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = Size.defaultOffset
        return stackView
    }()

    private let h2StackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = Size.defaultOffset
        return stackView
    }()

    private let vStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = Size.vStackViewSpacing
        return stackView
    }()

  
    // MARK: - Init


    init(sample : Sample) {
        super.init(frame: .zero)
        render()
        configure(with: sample)
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

        self.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.equalTo(horizontalLine).offset(Size.vStackViewTopOffset)
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
        }

        vStackView.addArrangedSubview(h1StackView)
        vStackView.addArrangedSubview(h2StackView)

        h1StackView.addArrangedSubview(materialStackView)
        h1StackView.addArrangedSubview(thicknessStackView)
        h1StackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        h2StackView.addArrangedSubview(sizeStackView)
        h2StackView.addArrangedSubview(makerStackView)
        h2StackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

    }

     func configure(with sample: Sample) {
        sampleNameLabel.text = sample.matName
        matPriceLabel.text = "장당 \(sample.matPrice)"
        materialStackView.setValueLabel(with: sample.material)
        thicknessStackView.setValueLabel(with: sample.thickness)
        sizeStackView.setValueLabel(with: sample.size)
        makerStackView.setValueLabel(with: sample.maker)
    }


}
