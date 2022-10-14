//
//  AreaTestViewController.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/09.
//

import UIKit

import SnapKit

final class AreaTestViewController: BaseViewController {

    // MARK: - Properties
    
    private let toBeEstimatedPriceView = ToBeEstimatedPriceView()
    private let estimatedPriceView = EstimatedPriceView(estimatedPrice: -1, width: 1100, height: 1200, estimatedQuantity: 80, pricePerBlock: -1)
    
    let getAreaViewController = GetAreaViewController()
    
    // MARK: - Life Cycle
    
    override func viewDidLayoutSubviews() {
        toBeEstimatedPriceView.textButton.layer.cornerRadius = toBeEstimatedPriceView.textButton.bounds.height/2
        estimatedPriceView.textButton.layer.cornerRadius = estimatedPriceView.textButton.bounds.height/2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegation()
    }
    
    override func render() {
        view.addSubview(toBeEstimatedPriceView)
        toBeEstimatedPriceView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(80)
        }

        view.addSubview(estimatedPriceView)
        estimatedPriceView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(80)
        }
    }
    
    override func configUI() {
        toBeEstimatedPriceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        toBeEstimatedPriceView.alpha = 1
        estimatedPriceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        estimatedPriceView.alpha = 0
    }
    
    
    // MARK: - Func
    
    private func setDelegation() {
        toBeEstimatedPriceView.delegate = self
        estimatedPriceView.delegate = self
        getAreaViewController.delegate = self
    }
    
    // TODO: - 샘플 정보에서 가져올 것: 장 당 가격, 샘플 크기
//    let exampleSamplePrice = 15000
    let exampleSamplePrice = -1
    let exampleSampleArea = 14400
    
    private func calculatePrice(width: Int, height: Int) -> [Int] {
        let estimatedQuantity = width*height / exampleSampleArea
        let estimatedPrice = exampleSamplePrice == -1 ? -1 : exampleSamplePrice * estimatedQuantity
        // FIXME: - 배열 말고 다른 방식 사용하기
        return [estimatedQuantity, estimatedPrice]
    }
}

extension AreaTestViewController: ShowModalDelegate {
    func buttonDidTapped() {
        getAreaViewController.preferredSheetSizing = .medium
        present(getAreaViewController, animated: true)
    }
}

extension AreaTestViewController: SaveSizeDelegate {
    func saveButtonTapped(widthString: String, heightString: String) {
        // FIXME: - 더 안정적으로 수정
        if widthString == "" || heightString == "" {
            toBeEstimatedPriceView.alpha = 1
            estimatedPriceView.alpha = 0
        } else {
            let quantityAndPrice = calculatePrice(width: Int(widthString) ?? 0, height: Int(heightString) ?? 0)
            estimatedPriceView.changeEstimation(estimatedPrice: quantityAndPrice[1], width: Int(widthString) ?? 0, height: Int(heightString) ?? 0, estimatedQuantity: quantityAndPrice[0], pricePerBlock: exampleSamplePrice)
            toBeEstimatedPriceView.alpha = 0
            estimatedPriceView.alpha = 1
        }
    }
}
