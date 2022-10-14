//
//  EstimateHistoryCollectionViewCell.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import UIKit

import SnapKit

class EstimateHistoryCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    
    private let fileManager = LocalFileManager.instance
    
    private let estimatedImageView: UIImageView = UIImageView()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render() {
        contentView.addSubview(estimatedImageView)
        estimatedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configUI() {
        
    }
    
    func configure(history: EstimateHistory) {
        let savingfolderName: String = "estimate-photo"
        let floorSegmentedImageName: String = "mat-inserted-photo"
        let imageName: String = floorSegmentedImageName + "-\(history.imageId)"
        
        let historyImage: UIImage = fileManager.getImage(imageName: imageName, folderName: savingfolderName) ?? UIImage()
        estimatedImageView.image = historyImage
    }
    
}
