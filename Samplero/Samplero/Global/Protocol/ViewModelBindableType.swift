//
//  ViewModelBindableType.swift
//  KaKaoProfile
//
//  Created by DaeSeong on 2022/09/30.
//

import Foundation
import UIKit

protocol ViewModelBindableType {
    associatedtype ViewModelType

    var viewModel: ViewModelType! { get set } // 왜 언랩핑을 해주는 거지
    func bind()
}

extension ViewModelBindableType where Self: UIViewController {
    mutating func bindViewModel(_ viewModel: Self.ViewModelType) {
        self.viewModel = viewModel // mutating을 사용하는 이유

        loadViewIfNeeded() // ViewController의 view가 아직 로드되지 않은 경우 로드함.
           bind()
    }
}
