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

    let db = DBHelper.shared

    var disposeBag: DisposeBag = DisposeBag()
    // 제거할 샘플
    let removedSample = PublishSubject<CheckSample>()
    // 선택된 샘플
    var selectedSample = PublishSubject<CheckSample>()


    // MARK: - Input

    struct Input {
        let viewWillDisappear: ControlEvent<Bool>
        let allChoiceButtonSelected: ControlEvent<Void>
        let allDeleteButtonSelected: ControlEvent<Void>
        let orderButtonSelected: ControlEvent<Void>
    }
    // MARK: - Output

    struct Output {
        let wishedSample: Observable<[CheckSample]>
        let IsWishedSampleEmpty: Observable<Bool>
        let selectionState: Observable<Set<CheckSample>>
        let selectedCountText: Driver<String>
        let selectionStateIsEmpty: Driver<Bool>
        let selectionTotalPrice: Observable<Int>
        let IsAllChoiceButtonSelected: Observable<Bool>
        let tappedAllChoiceButton: Observable<Bool>
        let tappedOrderButton: Observable<String>
    }


    // MARK: - Transfrom


    func transform(input: Input) -> Output {
        // 장바구니 목록 샘플
        let wishedSampleRelay = BehaviorRelay<[CheckSample]>(value: [])
        // 현재 선택된 샘플들 목록
        let selectionState = BehaviorRelay<Set<CheckSample>>(value: Set())
        // 복사된 샘플 목록 문자열
        let shopBasketCopy = BehaviorSubject(value: "")
        // 샘플 목록 전체 선택시 이용
        let selectedAllSample = PublishSubject<Void>()


        wishedSampleRelay.accept(self.db.getShopBasketItem().map { shopBasket in
            return shopBasket.toCheckSample() })


        // binding to selectionState
        Observable.of(
            selectedSample.map { SelectionEvent.sample($0) },
            selectedAllSample.withLatestFrom(wishedSampleRelay.map { SelectionEvent.all($0) })
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
                return lastSampleSet }
            .startWith(Set())
            .bind(to: selectionState)
            .disposed(by: disposeBag)


        // removedSample binding
        removedSample.map { removedCheckSample in
            return wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id == removedCheckSample.sample.id && checkSample.isChecked == true }
        }
        .filter { !$0.isEmpty }
        .map { $0[0] }
        .bind(to: selectedSample)
        .disposed(by: disposeBag)

        removedSample.map { removedCheckSample in
            return wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id != removedCheckSample.sample.id
            }
        }
        .bind(to: wishedSampleRelay)
        .disposed(by: disposeBag)

        removedSample.map { $0.sample.id }
            .subscribe(onNext: { id in
                self.db.deleteItemFromShopBasket(itemId: id)
            })
            .disposed(by: disposeBag)


        // viewWillDisappear
        input.viewWillDisappear
            .subscribe { _ in
                let items = wishedSampleRelay.value

                items.forEach { item in
                    self.db.updateShopBasketItemSelectedState(itemId: item.sample.id, shopBasketItem: item.isChecked)
                }
            }
            .disposed(by: disposeBag)


        // tappedAllDeleteButton
        let tappedAllDeleteButton =  input.allDeleteButtonSelected.asDriver()
        tappedAllDeleteButton
            .map({ [] })
            .drive(wishedSampleRelay)
            .disposed(by: disposeBag)
        tappedAllDeleteButton
            .map({ [] })
            .drive(selectionState)
            .disposed(by: disposeBag)
        tappedAllDeleteButton
            .asObservable()
            .subscribe { _ in
                self.db.deleteAllItemFromShopBasket() }
            .disposed(by: disposeBag)


        // wishedSample
        let IsWishedSampleEmpty = wishedSampleRelay.map { $0.isEmpty }


        // selectionState
        let selectedCountText = selectionState.map { "\($0.count)개의 샘플"}.asDriver(onErrorJustReturn: "0개의 샘플")

        let selectionStateIsEmpty = selectionState.map { $0.isEmpty }.asDriver(onErrorJustReturn: true)

        let selectionTotalPrice = selectionState.map { checkSamples in
            checkSamples.map { $0.sample.samplePrice }.reduce(0, +) }

        let IsAllChoiceButtonSelected = selectionState.map { _ in
            return selectionState.value.count == wishedSampleRelay.value.count }

        selectionState
            .map({ samples in
                var copyString: String = ""
                var number: Int = 0
                for sample in samples {
                    number += 1
                    copyString += "\(number). \(sample.sample.maker) \(sample.sample.matName)\n" }
                return copyString })
            .bind(to: shopBasketCopy)
            .disposed(by: disposeBag)


        // tappedAllChoiceButton
        let tappedAllChoiceButton =  input.allChoiceButtonSelected.map { _ in
            !(selectionState.value.count == wishedSampleRelay.value.count) }
            .map({ checkedFlag -> Bool in
                _ = wishedSampleRelay.value.map { $0.isChecked = checkedFlag }
                selectedAllSample.onNext(())
                return checkedFlag })


        // tappedOrderButton
        let tappedOrderButton = input.orderButtonSelected.withLatestFrom(shopBasketCopy.asObservable())


        return Output(wishedSample: wishedSampleRelay.asObservable(),
                      IsWishedSampleEmpty: IsWishedSampleEmpty,
                      selectionState: selectionState.asObservable(),
                      selectedCountText: selectedCountText,
                      selectionStateIsEmpty: selectionStateIsEmpty,
                      selectionTotalPrice: selectionTotalPrice,
                      IsAllChoiceButtonSelected: IsAllChoiceButtonSelected,
                      tappedAllChoiceButton: tappedAllChoiceButton,
                      tappedOrderButton: tappedOrderButton)

    }

}


