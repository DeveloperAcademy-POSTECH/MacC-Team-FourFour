//
//  ShopBasketCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/20.
//

import UIKit

import RxSwift

class ShopBasketCoordinator: BaseCoordinator {

    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    override func start() {
        var shopBasketVC = ShopBasketViewController()
        shopBasketVC.bindViewModel(ShopBasketViewModel(coordinator: self))
        navigationController?.pushViewController(shopBasketVC, animated: true)

    }
}
