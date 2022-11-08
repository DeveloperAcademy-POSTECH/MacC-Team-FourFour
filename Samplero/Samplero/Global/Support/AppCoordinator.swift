//
//  AppCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/07.
//

import UIKit

import RxSwift


class AppCoordinator: BaseCoordinator<Void> {

    private let window: UIWindow

    private let navigationController: UINavigationController

    init(window: UIWindow, navigationController: UINavigationController) {
        self.window = window
        self.window.rootViewController = navigationController
        self.navigationController = navigationController
    }


    override func start() -> Observable<Void> {
        let cameraCoordinator = CameraCoordinator(navigationController: navigationController)

        return coordinate(to: cameraCoordinator)

    }


}


