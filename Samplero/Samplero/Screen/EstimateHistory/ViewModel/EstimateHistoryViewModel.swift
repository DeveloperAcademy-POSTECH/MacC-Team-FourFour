//
//  EstimateHistoryViewModel.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import Foundation

import RxSwift

class EstimateHistoryViewModel {
    
    // MARK: - Properties
    
    let db = DBHelper.shared
    
    var disposeBag = DisposeBag()
    
    let estimateHistorySubject: BehaviorSubject<[EstimateHistory]>
    
    init () {
        var estimateHistories: [EstimateHistory] = []
        estimateHistories = db.getEstimateHistories()
        
        estimateHistorySubject = BehaviorSubject(value: estimateHistories)
    }
}
