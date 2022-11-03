//
//  Sample.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import Foundation
import CoreGraphics

struct Samples {
    var samples: [Sample] = []

    func isAdded(sample: Sample) -> Bool {
        return samples.contains(sample)
    }

    mutating func addSample(sample: Sample) {
        samples.append(sample)
    }
}

struct Sample {
    let id: Int
    let matName: String
    let imageName: String
    let matPrice: Int
    let samplePrice: Int
    let material: String
    let thickness: Double
    let size: CGSize
    let maker: String
}
 // To use Set Collection
extension Sample: Hashable {
    static func == (lhs: Sample, rhs: Sample) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


