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
    case sample(CheckSample)
    case all([CheckSample])
}

class ShopBasketViewModel {


    // MARK: - Properties


    var disposeBag: DisposeBag = DisposeBag()
    let wishedSampleRelay = BehaviorRelay<[CheckSample]>(value: MockData.sampleList.map{CheckSample(sample: $0)})
    let removedSubejct = PublishSubject<CheckSample>()
    // current selected checkSample collection
    var selectionState = PublishSubject<Set<CheckSample>>()
    // selected checkSample
    var selectedSubject = PublishSubject<CheckSample>()
    // FIXME: - 필요성 검토
    var selectedAllSubject = PublishSubject<[CheckSample]>()


    // MARK: - Init


    init() {
        // withLatestFrom - selectedAllSubject가 이벤트 방출할 때 wishedSampleRelay의 가장 최근에 방출한 이벤트와 결합해서 방출가능. but 클로저사용안하면 wishedSampleRelay의 가장 최근 이벤트만 방출.

        // scan의 초기값(Last보관소)은 첫번째 인자이고 두번째 인자인 핸들러를 통해 이전에 방출한 값과 위에서 방출한 이벤트값을 이용해 새로운 이벤트를 방출하고 Last보관소에 다시 저장한다.

        // binding to selectionState
        Observable.of(
            selectedSubject.map { SelectionEvent.sample($0) },
            selectedAllSubject.withLatestFrom(wishedSampleRelay.map { SelectionEvent.all($0) })
                 ).merge()
            .scan(Set()) { (lastSampleSet: Set<CheckSample>, event: SelectionEvent) in
                var lastSampleSet = lastSampleSet
                switch event {
                case .sample(let checkSample):
                    if lastSampleSet.contains(checkSample) {
                        lastSampleSet.remove(checkSample)
                    } else {
                        lastSampleSet.insert(checkSample)
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

        // removedSubejct binding
        removedSubejct.map { removedCheckSample in
            return self.wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id == removedCheckSample.sample.id && checkSample.isChecked == true
            }
        }
        .filter {!$0.isEmpty}
        .map { $0[0]}
        .bind(to: selectedSubject)
        .disposed(by: disposeBag)

        removedSubejct.map { removedCheckSample in
            return self.wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id != removedCheckSample.sample.id
            }
        }
        .bind(to: wishedSampleRelay)
        .disposed(by: disposeBag)


        let inputNum  = PublishSubject<Int>()
        let inputStr = PublishSubject<String>()


    }
}

