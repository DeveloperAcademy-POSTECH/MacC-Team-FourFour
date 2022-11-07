//
//  CameraCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/07.
//

import UIKit
import RxSwift

class CameraCoordinator: BaseCoordinator<Void> {

    weak var navigationViewController: UINavigationController?

    init(navigationViewController: UINavigationController) {
        self.navigationViewController = navigationViewController
    }

    override func start() -> Observable<Void> {
        var cameraVC = CameraViewController()
        navigationViewController?.pushViewController(cameraVC, animated: true)
        return .never()
    }

    private func showEstimateHistory() {
        var estimateHistoryVC = EstimateHistoryViewController()
        estimateHistoryVC.bindViewModel(EstimateHistoryViewModel())
        navigationViewController?.pushViewController(estimateHistoryVC, animated: true)
    }

    private func showTakenPicture() {
        var takenPictureVC = TakenPictureViewController()
        navigationViewController?.pushViewController(takenPictureVC, animated: true)
    }

    private func showShopBasket() {
        var shopBasketVC = ShopBasketViewController()
        navigationViewController?.pushViewController(shopBasketVC, animated: true)
    }
}
