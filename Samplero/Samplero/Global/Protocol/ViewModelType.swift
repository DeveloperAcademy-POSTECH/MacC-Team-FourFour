//
//  ViewModelType.swift
//  KaKaoProfile
//
//  Created by DaeSeong on 2022/09/30.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype Coordinator
    var disposeBag: DisposeBag { get set }

    init(coordinator: Coordinator)
    func transform(input: Input) -> Output

}
