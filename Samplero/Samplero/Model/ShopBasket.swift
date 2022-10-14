//
//  ShopBasket.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/14.
//

import Foundation

struct ShopBasket {
    let id: Int
    let sampleId: Int
    var isSelected: Bool = false

    func toCheckSample() -> CheckSample {
        let sample = MockData.sampleList.filter { sample in
            return sample.id == self.sampleId
        }

        return CheckSample(sample: sample[0], isChecked: isSelected)
    }
}
