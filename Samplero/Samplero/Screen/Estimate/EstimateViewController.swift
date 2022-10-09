//
//  EstimateViewController.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/08.
//

import UIKit

import SnapKit

private enum Size {
    static let deviceHeight = UIScreen.main.bounds.size.height - ((UIApplication.shared.windows.first?.safeAreaInsets.top) ??  0) - 44
    static let defaultOffset = 20
    static let samplePriceTopOffset = 28
    static let samplePriceValueLeadingOffset = 23
    static let sampleAddButtonWidth = 100
    static let sampleAddButtonHeight = 39
    static let sampleAddButtonTopOffset = 17

}

class EstimateViewController: BaseViewController {


    // MARK: - Properties
    private let roomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = ImageLiteral.sampleRoom
        return imageView
    }()

    private let sampleDetailView = SampleDetailView(sample: MockData.sampleList[0])

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()

    private let samplePriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 14)
        label.text = "샘플가격"
        label.textColor = .systemGray2
        return label
    }()

    private let samplePriceValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.text = "5000원"
        return label
    }()

    private let sampleAddButton: UIButton = {
        let button = UIButton()
        button.setTitle("샘플담기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        return button
    }()


    // MARK: - Life Cycle


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func render() {
        view.addSubview(roomImageView)
        roomImageView.snp.makeConstraints { make in
            make.height.equalTo(Size.deviceHeight*0.69)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        view.addSubview(sampleDetailView)
        sampleDetailView.snp.makeConstraints { make in
            make.top.equalTo(roomImageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Size.deviceHeight*0.2)
        }

        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(sampleDetailView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        bottomView.addSubview(samplePriceLabel)
        samplePriceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.samplePriceTopOffset)
            make.leading.equalToSuperview().offset(Size.defaultOffset)
        }
        bottomView.addSubview(samplePriceValueLabel)
        samplePriceValueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.samplePriceTopOffset)
            make.leading.equalTo(samplePriceLabel.snp.trailing).offset(Size.samplePriceValueLeadingOffset)
        }

        bottomView.addSubview(sampleAddButton)
        sampleAddButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.sampleAddButtonTopOffset)
            make.trailing.equalTo(-Size.defaultOffset)
            make.width.equalTo(Size.sampleAddButtonWidth)
            make.height.equalTo(Size.sampleAddButtonHeight)

        }
    }

    override func configUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: ImageLiteral.shoppingBag, style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = .black

    }

}
