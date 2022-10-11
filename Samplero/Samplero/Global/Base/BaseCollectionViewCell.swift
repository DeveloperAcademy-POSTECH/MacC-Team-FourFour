//
//  BaseCollectionViewCell.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render() {
        
    }
    
    func configUI() {
        
    }
    
}
