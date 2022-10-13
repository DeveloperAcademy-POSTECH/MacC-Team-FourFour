//
//  ShopBasketViewModel.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/12.
//

import UIKit

import RxCocoa
import RxSwift


private enum SelectionEvent {
    case sample(Sample)
    case all([Sample])
}

class ShopBasketViewModel {


    // MARK: - Properties


    var disposeBag: DisposeBag = DisposeBag()
    let wishedSampleObservable = BehaviorRelay<[Sample]>(value: MockData.sampleList)
    let remove = PublishSubject<Sample>()
    var selectionState = PublishSubject<Set<Sample>>()
    var selectedSubject = PublishSubject<Sample>()
    var selectedAllSubject = PublishSubject<[Sample]>()


    // MARK: - Init


    init() {
        Observable.of(
            selectedSubject.map { SelectionEvent.sample($0) },
            selectedAllSubject.withLatestFrom(wishedSampleObservable.map { SelectionEvent.all($0) })
                 ).merge()
            .scan(Set()) { (lastSampleSet: Set<Sample>, event: SelectionEvent) in
                var lastSampleSet = lastSampleSet
                switch event {
                case .sample(let sample):
                    if lastSampleSet.contains(sample) {
                        lastSampleSet.remove(sample)
                    } else {
                        lastSampleSet.insert(sample)
                    }
                case .all(let all):
                    if lastSampleSet == Set(all) {
                        lastSampleSet = Set()
                    } else {
                        lastSampleSet = Set(all)
                    }
                }
                return lastSampleSet
            }
            .startWith(Set())
            .bind(to: selectionState)
            .disposed(by: disposeBag)

        remove.map { removedSample in
            return self.wishedSampleObservable.value.filter { sample -> Bool in
                sample.matName != removedSample.matName
            }
        }
        .bind(to: wishedSampleObservable)
        .disposed(by: disposeBag)


    }
}

