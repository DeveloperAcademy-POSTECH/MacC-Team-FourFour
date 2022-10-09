//
//  ViewModelType.swift
//  KakaoProfile
//
//  Created by DaeSeong on 2022/09/30.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var disposeBag: DisposeBag { get set }

    func transform(input: Input) -> Output

}
