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
    let width: Double?
    let height: Double?
    let selectedSampleId: Int?
    
    func getImage() -> UIImage? {
        return UIImage(named: "sample_photo_\(imageId)")
    }
}
