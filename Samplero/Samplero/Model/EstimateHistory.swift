//
//  EstimateHistory.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import UIKit

struct EstimateHistory {
    let imageId: Int
    let estimateDate: Date
    
    func getImage() -> UIImage? {
        return UIImage(named: "sample_photo_\(imageId)")
    }
}

#if DEBUG
extension EstimateHistory {
    static let mockData: [EstimateHistory] = [
        EstimateHistory(imageId: 0, estimateDate: Date()),
        EstimateHistory(imageId: 1, estimateDate: Date()),
        EstimateHistory(imageId: 2, estimateDate: Date()),
        EstimateHistory(imageId: 3, estimateDate: Date()),
        EstimateHistory(imageId: 4, estimateDate: Date()),
        EstimateHistory(imageId: 5, estimateDate: Date()),
        EstimateHistory(imageId: 6, estimateDate: Date()),
        EstimateHistory(imageId: 7, estimateDate: Date())
    ]
}
#endif
