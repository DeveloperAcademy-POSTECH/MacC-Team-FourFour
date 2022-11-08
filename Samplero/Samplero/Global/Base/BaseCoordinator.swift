//
//  BaseCoordinator.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/07.
//

import UIKit

import RxSwift

class BaseCoordinator {

// TODO: - 필요성을 못 느껴서 주석처리함.
    
//    private let identifier = UUID()
//
//    private var childCoordinators = [UUID: Any]()
//
//    private func store(coordinator: BaseCoordinator) {
//        childCoordinators[coordinator.identifier] = coordinator
//    }
//
//    private func free(coordinator: BaseCoordinator) {
//        childCoordinators[coordinator.identifier] = nil
//    }
//
//    func coordinate(to coordinator: BaseCoordinator) {
//        store(coordinator: coordinator)
//        return coordinator.start()
//    }

    func start() {
        fatalError("Start method should be implemented.")
    }
}
