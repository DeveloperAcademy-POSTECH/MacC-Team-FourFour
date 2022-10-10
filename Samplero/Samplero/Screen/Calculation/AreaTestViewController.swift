//
//  AreaTestViewController.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/09.
//

import UIKit

import SnapKit

final class AreaTestViewController: BaseViewController {

    // MARK: - Properties
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "예상 가격"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let getAreaButton = UIView()
    
    private let textButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .light)
        button.tintColor = .white
        button.setTitle("견적 계산을 위해 공간의 면적을 입력해주세요", for: .normal)
        return button
    }()
    
    private let roundedRectangle: UIView = {
        let rect = UIView()
        rect.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return rect
    }()
    
    private let priceAndAreaStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Func
    override func render() {
        getAreaButton.addSubview(roundedRectangle)
        getAreaButton.addSubview(textButton)
        priceAndAreaStackView.addArrangedSubview(priceLabel)
        priceAndAreaStackView.addArrangedSubview(getAreaButton)
        view.addSubview(priceAndAreaStackView)
    }
    
    override func configUI() {
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(23)
        }
        
        textButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(23)
            make.center.equalToSuperview()
        }
        
        roundedRectangle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.center.equalToSuperview()
            make.width.equalTo(textButton).multipliedBy(1.1)
            make.height.equalTo(textButton).multipliedBy(1.25)
        }
        
        priceAndAreaStackView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(80)
        }
    }
    
    @objc func buttonDidTap() {
        let viewController = GetAreaViewController()
        viewController.preferredSheetSizing = .medium
        present(viewController, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        roundedRectangle.bounds = .init(origin: textButton.center, size: CGSize(width: roundedRectangle.frame.width, height: roundedRectangle.frame.height))
        roundedRectangle.layer.roundCorners(radius: 21)
    }
}

extension CALayer {
   func roundCorners(radius: CGFloat) {
       let roundPath = UIBezierPath(
        roundedRect: self.bounds,
           cornerRadius: radius)
       let maskLayer = CAShapeLayer()
       maskLayer.path = roundPath.cgPath
       self.mask = maskLayer
       
       let borderLayer = CAShapeLayer()
       borderLayer.path = maskLayer.path
       borderLayer.fillColor = nil
       borderLayer.strokeColor = UIColor.white.cgColor
       borderLayer.lineWidth = 1
       borderLayer.frame = .init(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
       self.addSublayer(borderLayer)
   }

}
