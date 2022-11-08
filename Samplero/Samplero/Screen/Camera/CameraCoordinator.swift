//
//  CameraCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/07.
//

import UIKit
import RxSwift

class CameraCoordinator: BaseCoordinator {

    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    override func start() {
        var cameraVC = CameraViewController()
        cameraVC.bindViewModel(CameraViewModel(coordinator: self))
        navigationController?.pushViewController(cameraVC, animated: true)
    }

     func showEstimateHistory() {
        var estimateHistoryVC = EstimateHistoryViewController()
        estimateHistoryVC.bindViewModel(EstimateHistoryViewModel())
         navigationController?.pushViewController(estimateHistoryVC, animated: true)
    }

    func showTakenPicture(image: UIImage) {
        if let imagePickerVC = navigationController?.presentedViewController {
            imagePickerVC.dismiss(animated: true)
        }

        guard let cameraVC = navigationController?.viewControllers.last as? CameraViewController else { return }
        cameraVC.takenPictureViewController.configPictureImage(image: image)
        navigationController?.present(cameraVC.takenPictureViewController, animated: true)
        cameraVC.session.rx.stopRunning()
    }

     func showShopBasket() {
        var shopBasketVC = ShopBasketViewController()
         shopBasketVC.bindViewModel(ShopBasketViewModel())
         navigationController?.pushViewController(shopBasketVC, animated: true)
    }

    func showImagePicker(imagePickerVC: UIImagePickerController) {
        navigationController?.present(imagePickerVC, animated: true)
    }

    func showEstimate(takenPictureIndex: Int) {
        hidePresentView() // TakenPictureViewController 해제
        var estimateVC = EstimateViewController()
        estimateVC.bindViewModel(EstimateViewModel())
        estimateVC.viewModel.imageIndex = takenPictureIndex
        self.navigationController?.pushViewController(estimateVC, animated: true)

        guard let lastVC = navigationController?.presentedViewController else { return }
        guard let takenPictureVC = lastVC as? TakenPictureViewController else { return }
        takenPictureVC.stopLottieAnimation()
    }

    func hidePresentView() {
        navigationController?.presentedViewController?.dismiss(animated: true)
    }
}
