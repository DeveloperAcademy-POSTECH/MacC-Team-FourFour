//
//  UICollectionView+Extension.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(withType cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as? T else {
            fatalError("Could not find cell with reuseID \(T.className)")
        }
        return cell
    }
    
    func register<T>(cell: T.Type, forCellReuseIdentifier reuseIdentifier: String = T.className) where T: UICollectionViewCell {
        register(cell, forCellWithReuseIdentifier: reuseIdentifier)
    }
}
