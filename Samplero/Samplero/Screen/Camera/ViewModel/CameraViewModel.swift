//
//  CameraViewModel.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/14.
//

import Foundation

import RxSwift

class CameraViewModel {
    // MARK: - Properties
    
    let db = DBHelper.shared
    
    var disposeBag = DisposeBag()
    
    let estimateHistoryObservable: Observable<[EstimateHistory]>
    
    init () {
        var estimateHistories: [EstimateHistory] = []
        estimateHistories = db.getEstimateHistories()
        
        estimateHistoryObservable = Observable.of(estimateHistories)
    }
}
