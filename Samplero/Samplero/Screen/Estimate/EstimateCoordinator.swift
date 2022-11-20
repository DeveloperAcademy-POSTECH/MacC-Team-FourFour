//
//  EstimateCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/20.
//

import UIKit

import RxSwift

class EstimateCoordinator: BaseCoordinator {

    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    override func start() {
        var estimateVC = EstimateViewController()
        estimateVC.bindViewModel(EstimateViewModel(coordinator: self))
        navigationController?.pushViewController(estimateVC, animated: true)

    }

    func start(with imageIndex: Int) {
        var estimateVC = EstimateViewController()
        estimateVC.bindViewModel(EstimateViewModel(coordinator: self))
        estimateVC.viewModel.imageIndex = imageIndex
        navigationController?.pushViewController(estimateVC, animated: true)
    }

    func showShopBasket() {
        let shopBasketCoordinator = ShopBasketCoordinator(navigationController: navigationController)
        shopBasketCoordinator.start()
    }
}
