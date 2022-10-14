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
    private let estimatedPriceView = EstimatedPriceView(estimatedPrice: "1,200,000원", width: 1100, height: 1200, estimatedQuantity: 80, pricePerBlock: "15,000")
    
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
            make.center.equalToSuperview().inset(100)
            make.height.equalTo(80)
        }
        
        view.addSubview(estimatedPriceView)
        estimatedPriceView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.center.equalToSuperview().offset(100)
            make.height.equalTo(80)
        }
    }
    
    override func configUI() {
        toBeEstimatedPriceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        estimatedPriceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    
    // MARK: - Func
    
    @objc func buttonDidTap() {
        let viewController = GetAreaViewController()
        viewController.preferredSheetSizing = .medium
        present(viewController, animated: true)
    }
    
    private func setDelegation() {
        toBeEstimatedPriceView.delegate = self
        estimatedPriceView.delegate = self
    }
}

extension AreaTestViewController: ShowModalDelegate {
    func buttonDidTapped() {
        let viewController = GetAreaViewController()
        viewController.preferredSheetSizing = .medium
        present(viewController, animated: true)
    }
}
