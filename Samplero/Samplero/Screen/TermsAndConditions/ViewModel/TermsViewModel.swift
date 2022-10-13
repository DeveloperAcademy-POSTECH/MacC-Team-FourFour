//
//  TermsViewModel.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/13.
//

import Foundation

import RxSwift
import RxCocoa

class TermsViewModel {
    var disposeBag = DisposeBag()
    
    var isChecked: Bool
    var checkboxObservable: BehaviorSubject<Bool>
    
    init(isChecked: Bool) {
        self.isChecked = isChecked
        self.checkboxObservable = BehaviorSubject(value: self.isChecked)
    }
}
