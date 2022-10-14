//
//  SampleCollectionViewCell.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import UIKit

import SnapKit

private enum Size {
    static let checkedViewPadding = 10
    static let sampleImageBorderWidth = 2.0
    static let sampleImageCornerRadius = 6.0

}

final class SampleCollectionViewCell: UICollectionViewCell {


    // MARK: - Properties

    private let sampleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "CozyBaby")
        imageView.layer.borderWidth = Size.sampleImageBorderWidth
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = Size.sampleImageCornerRadius
        return imageView
    }()

    private let checkedView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override var isSelected: Bool {
            didSet {
                checkedView.image = isSelected ? UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
                : UIImage()
                sampleImageView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor
                : UIColor.white.cgColor
            }
        }

    // MARK: - Init

        override init(frame: CGRect) {
            super.init(frame: frame)
            render()
        }

        required init?(coder: NSCoder) {
            fatalError("init(corder:) has not been implemented")
        }


    // MARK: - Func

    private func render() {
        contentView.addSubview(sampleImageView)
        sampleImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sampleImageView.addSubview(checkedView)
        checkedView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Size.checkedViewPadding)
        }
    }

    func configure(with image: String) {
        sampleImageView.image = UIImage(named: image)
    }

    
}
