//
//  BaseViewController.swift
//  HelloRxSwift
//
//  Created by Minkyeong Ko on 2022/10/06.
//

import UIKit

import Lottie
import SnapKit

class BaseViewController: UIViewController {


    // MARK: - Properties
    private var lottieView: AnimationView?
    private let backgroundView = UIView()


    // MARK: - Life Cycle


    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        configUI()

    }
    
    func render() {
        // auto layout 관련 코드들 모아놓는 곳
    }
    
    func configUI() {
        // UI 관련 코드들 모아놓는 곳
        view.backgroundColor = .systemBackground
    }

    func setupLottieView() {
        lottieView = LottieAnimationView(name: "dots")
        guard let lottieView = lottieView else { return }
        backgroundView.frame = view.frame

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(250)
        }

        lottieView.loopMode = .loop
        lottieView.play()
    }

    func stopLottieAnimation() {
        lottieView?.stop()
        lottieView?.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
    
}
