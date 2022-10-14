//
//  ShopBasketCollectionViewCell.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/12.
//

import UIKit

import RxCocoa
import RxSwift

private enum Size {
    static let sampleImage = 80.0
    static let defaultOffset = 20.0
    static let checkBox = 20.0
    static let secondaryOffset = 16
    static let checkBoxFrameSize = 36.0
}

final class ShopBasketCollectionViewCell: BaseCollectionViewCell {


    // MARK: - Properties
    // Cell consists of checkBox,sampleImageView, verticalStackView


    private let checkBox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.imageView?.tintColor = .systemGray3
        button.imageEdgeInsets = UIEdgeInsets(top: .zero,
                                              left: .zero,
                                              bottom: Size.checkBoxFrameSize / 2,
                                              right: Size.checkBoxFrameSize / 2)
       // button.backgroundColor = .systemPink  // TODO: - 삭제 예정
        return button
    }()

    private let sampleImageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "WhiteMarble")
        return imageView
    }()

    // verticalStackView consists of firstHorizontalStackView, matNameLabel, thicknessLabel,samplePriceLabel
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 1.33
        return stackView
    }()

    // firstHorizontalStackView consists of makerLabel,deleteButton
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let makerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "봄봄매트"
        label.textColor = .label
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.tintColor = .systemGray3
        return button
    }()

    private let matNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.text = "화이트마블"
        label.textColor = .label
        return label
    }()

    private let thicknessLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "두께: 4cm"
        label.textColor = .label
        label.alpha = 0.6
        return label
    }()

    private let samplePriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.text = "0원"
        label.textColor = .systemBlue
        label.textAlignment = .right
        return label
    }()

    var isChecked: Bool = false {
        didSet {
            if isChecked {
                checkBox.setImage(UIImage(systemName: "square.fill"), for: .normal)
                checkBox.imageView?.tintColor = .accent

            } else {
                checkBox.setImage(UIImage(systemName: "square"), for: .normal)
                checkBox.imageView?.tintColor = .systemGray4

            }
        }
    }

    var disposeBag: DisposeBag?

    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        isChecked = false
    }



    // MARK: - Func


    override func render() {

        contentView.addSubview(checkBox)
        checkBox.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Size.defaultOffset)
            make.size.equalTo(Size.checkBoxFrameSize)

        }

        contentView.addSubview(sampleImageView)
        sampleImageView.snp.makeConstraints { make in
            make.leading.equalTo(checkBox.snp.trailing)
            make.size.equalTo(Size.sampleImage)
            make.top.bottom.equalToSuperview()
        }

        contentView.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.leading.equalTo(sampleImageView.snp.trailing).offset(Size.secondaryOffset)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(Size.defaultOffset)
        }

        verticalStackView.addArrangedSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }

        horizontalStackView.addArrangedSubview(makerLabel)
        horizontalStackView.addArrangedSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(Size.defaultOffset)
        }

        verticalStackView.addArrangedSubview(matNameLabel)
        verticalStackView.addArrangedSubview(thicknessLabel)
        verticalStackView.addArrangedSubview(samplePriceLabel)
        samplePriceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
    }

    func getCheckButton() -> UIButton {
        return checkBox
    }

    func getDeleteButton() -> UIButton {
        return deleteButton
    }

    func configure(with checkSample: CheckSample) {
        let sample = checkSample.sample
        sampleImageView.image = UIImage(named: sample.imageName)
        makerLabel.text = sample.maker
        matNameLabel.text = sample.matName
        thicknessLabel.text = "\(sample.thickness)cm"
        samplePriceLabel.text = "\(sample.samplePrice)원"
        isChecked = checkSample.isChecked
    }
}

