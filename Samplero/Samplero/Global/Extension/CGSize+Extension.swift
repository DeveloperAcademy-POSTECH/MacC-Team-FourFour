//
//  CGSize+Extension.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/11.
//

import Foundation
import CoreGraphics

extension CGSize {
    var toString: String {
        return "\(Int(self.height).description)x\(Int(self.width).description)"
    }
}
