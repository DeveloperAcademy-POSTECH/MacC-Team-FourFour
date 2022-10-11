//
//  TakenPictureViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import AVFoundation
import UIKit

import RxCocoa
import RxSwift
import SnapKit

class TakenPictureViewController: BaseViewController {
    
    // MARK: - Properties
    
    // Rx
    private var disposeBag = DisposeBag()
    
    // Picture view
    private let takenPictureImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Top Drawer
    private let topDrawer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // Bottom Drawer
    private let bottomDrawer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // Retake Button
    private let retakeButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("다시찍기", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        return button
    }()
    
    // Next Button
    private let nextButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        return button
    }()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    override func render() {
        view.addSubview(takenPictureImageView)
        
        view.addSubview(topDrawer)
        topDrawer.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 6.975)
        }
        
        view.addSubview(bottomDrawer)
        bottomDrawer.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 4.157)
        }
        
        takenPictureImageView.snp.makeConstraints { make in
            make.top.equalTo(topDrawer.snp.bottom)
            make.bottom.equalTo(bottomDrawer.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(retakeButton)
        retakeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(44)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(44)
        }
    }
    
    // MARK: - Func
    
    func configPictureImage(image: UIImage) {
        takenPictureImageView.image = image
    }
    
    private func addTargets() {
        retakeButton.rx.tap.bind {
            print("clicked retake picture button")
        }.disposed(by: disposeBag)
        
        nextButton.rx.tap.bind {
            // TODO: go next
            print("clicked next button")
        }.disposed(by: disposeBag)
    }
    
    func getRetakeButton() -> UIButton {
        return retakeButton
    }
}
