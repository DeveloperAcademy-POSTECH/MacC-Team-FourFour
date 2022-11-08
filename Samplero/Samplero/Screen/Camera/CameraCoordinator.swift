//
//  CameraCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/07.
//

import UIKit
import RxSwift

class CameraCoordinator: BaseCoordinator<Void> {

    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() -> Observable<Void> {
        var cameraVC = CameraViewController()
        cameraVC.bindViewModel(CameraViewModel(coordinator: self))
        navigationController?.pushViewController(cameraVC, animated: true)
        return .never()
    }

     func showEstimateHistory() {
        var estimateHistoryVC = EstimateHistoryViewController()
        estimateHistoryVC.bindViewModel(EstimateHistoryViewModel())
         navigationController?.pushViewController(estimateHistoryVC, animated: true)
    }

     func showTakenPicture() {
        var takenPictureVC = TakenPictureViewController()
         navigationController?.pushViewController(takenPictureVC, animated: true)
    }

     func showShopBasket() {
        var shopBasketVC = ShopBasketViewController()
         shopBasketVC.bindViewModel(ShopBasketViewModel())
         navigationController?.pushViewController(shopBasketVC, animated: true)
    }

    func showImagePicker(imagePickerVC: UIImagePickerController) {
        navigationController?.present(imagePickerVC, animated: true)
    }

    func hidePresentView() {
        navigationController?.viewControllers.last?.dismiss(animated: true)
    }
}
