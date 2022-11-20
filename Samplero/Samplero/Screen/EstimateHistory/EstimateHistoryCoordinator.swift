//
//  EstimateHistoryCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/20.
//

import UIKit



class EstimateHistoryCoordinator: BaseCoordinator {

    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    override func start() {
        var estimateHistoryVC = EstimateHistoryViewController()
        estimateHistoryVC.bindViewModel(EstimateHistoryViewModel(coordinator: self))
        navigationController?.pushViewController(estimateHistoryVC, animated: true)

    }

    func showEstimate(with imageIndex: Int) {
        let estimateCoordinator = EstimateCoordinator(navigationController: navigationController)
        estimateCoordinator.start(with: imageIndex)
    }
}
