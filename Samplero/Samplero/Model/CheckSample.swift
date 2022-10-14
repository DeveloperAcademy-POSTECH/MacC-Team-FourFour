//
//  CheckSample.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/13.
//

import Foundation


class CheckSample {
    let sample: Sample
    var isChecked: Bool

    init(sample: Sample, isChecked: Bool = false) {
        self.sample = sample
        self.isChecked = isChecked
    }
}

extension CheckSample: Hashable {

    static func == (lhs: CheckSample, rhs: CheckSample) -> Bool {
        return lhs.sample.id == rhs.sample.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(sample.id)
    }
}

