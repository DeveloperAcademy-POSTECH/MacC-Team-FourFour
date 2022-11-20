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
        let estimateHistoryCoordinator = EstimateHistoryCoordinator(navigationController: navigationController)
        estimateHistoryCoordinator.start()
    }

    func showTakenPicture(image: UIImage) {
        if let imagePickerVC = navigationController?.presentedViewController {
            imagePickerVC.dismiss(animated: true) }

        guard let cameraVC = navigationController?.viewControllers.last as? CameraViewController else { return }
        cameraVC.takenPictureViewController.configPictureImage(image: image)
        navigationController?.present(cameraVC.takenPictureViewController, animated: true)
        cameraVC.session.rx.stopRunning()
    }

    func showShopBasket() {
        let shopBasketCoordinator = ShopBasketCoordinator(navigationController: navigationController)
        shopBasketCoordinator.start()
    }

    func showImagePicker(imagePickerVC: UIImagePickerController) {
        navigationController?.present(imagePickerVC, animated: true)
    }

    func showEstimate(takenPictureIndex: Int) {
        hidePresentedView() // TakenPictureViewController 해제
        let estimateCoordinator = EstimateCoordinator(navigationController: navigationController)
        estimateCoordinator.start(with: takenPictureIndex)

        guard let lastVC = navigationController?.presentedViewController else { return }
        guard let takenPictureVC = lastVC as? TakenPictureViewController else { return }
        takenPictureVC.stopLottieAnimation()
    }

    func hidePresentedView() {
        navigationController?.presentedViewController?.dismiss(animated: true)
    }
}
