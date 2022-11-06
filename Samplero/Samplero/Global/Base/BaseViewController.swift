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
    private var lottieView: LottieAnimationView?
    private let backgroundView = UIView()
    private let lottieViewBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.2
        view.layer.cornerRadius = 10
        return view
    }()


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
        lottieView = LottieAnimationView(name: "dot")
        guard let lottieView = lottieView else { return }
        backgroundView.frame = view.frame

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(lottieViewBackgroundView)
        lottieViewBackgroundView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(70)
        }

        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(300)
        }

        lottieView.loopMode = .loop
        lottieView.play()
    }

    func stopLottieAnimation() {
        lottieView?.stop()
        lottieView?.removeFromSuperview()
        lottieViewBackgroundView.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
    
}
