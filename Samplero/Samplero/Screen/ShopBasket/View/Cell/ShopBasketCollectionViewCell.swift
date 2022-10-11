//
//  ShopBasketCollectionViewCell.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/12.
//

import UIKit


private enum Size {
    static let sampleImageSize = 80
}
class ShopBasketCollectionViewCell: UICollectionViewCell {


    // MARK: - Properties

    private let checkBox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.fill"), for: .normal)
        button.imageView?.tintColor = .systemGray3
        return button
    }()

    private let sampleImageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .red
        return imageView
    }()
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Func


    private func render() {
        contentView.addSubview(checkBox)
        checkBox.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        contentView.addSubview(sampleImageView)
        sampleImageView.snp.makeConstraints { make in
            make.size.equalTo(Size.sampleImageSize)
            make.leading.equalTo(checkBox.snp.trailing).offset(16)
            make.top.bottom.equalToSuperview()
        }
    }


}

