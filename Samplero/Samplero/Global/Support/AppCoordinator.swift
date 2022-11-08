//
//  AppCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/07.
//

import UIKit

import RxSwift


class AppCoordinator: BaseCoordinator {

    private let window: UIWindow

    weak var navigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
        let navigationController = UINavigationController()
        navigationController.navigationBar.tintColor = UIColor.black
        self.navigationController = navigationController
        self.window.rootViewController = navigationController

    }


    override func start() {
        let cameraCoordinator = CameraCoordinator(navigationController: navigationController)

        cameraCoordinator.start()

    }


}


