//
//  CameraHelpView.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/12.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

class CameraHelpView: UIView {

    // MARK: - Properties
    
    private let couchMarkGuideImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "couchMarkGuideImage")
        return imageView
    }()
    
    private let couchMarkGuideLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "사진을 찍어\n예상 가격과 모습을 확인하고\n샘플매트 주문까지 간편하게 해보세요!"
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    // Couch Mark Indicator
    private let cartMarkIndicator: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let estimateHistoryMarkIndicator: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let getLibraryPhotoMarkIndicator: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // Couch Mark Label
    private let cartMarkLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "장바구니"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    private let estimateHistoryMarkLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "견적내역"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    private let getLibraryPhotoMarkLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "갤러리 사진 가져오기"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    let xMarkButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 23
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black.withAlphaComponent(0.5)
        
        addSubview(couchMarkGuideImageView)
        couchMarkGuideImageView.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        
        addSubview(couchMarkGuideLabel)
        couchMarkGuideLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(couchMarkGuideImageView.snp.bottom).offset(36)
        }
        
        [cartMarkIndicator, estimateHistoryMarkIndicator, getLibraryPhotoMarkIndicator,
         cartMarkLabel, estimateHistoryMarkLabel, getLibraryPhotoMarkLabel].forEach {
            addSubview($0)
        }
        
        cartMarkLabel.snp.makeConstraints { make in
            make.centerX.equalTo(snp.trailing).inset(UIScreen.main.bounds.width / 8.86)
            make.bottom.equalToSuperview().inset(37)
        }
        cartMarkIndicator.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(32)
            make.centerX.equalTo(snp.trailing).inset(UIScreen.main.bounds.width / 8.86)
            make.bottom.equalToSuperview()
        }
        
        estimateHistoryMarkLabel.snp.makeConstraints { make in
            make.centerX.equalTo(snp.leading).inset(UIScreen.main.bounds.width / 8.86)
            make.bottom.equalToSuperview().inset(37)
        }
        estimateHistoryMarkIndicator.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(32)
            make.centerX.equalTo(snp.leading).inset(UIScreen.main.bounds.width / 8.86)
            make.bottom.equalToSuperview()
        }
        
        getLibraryPhotoMarkLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height / 4.58)
            make.centerX.equalToSuperview()
        }
        getLibraryPhotoMarkIndicator.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height / 5.55 - 4)
            make.bottom.equalTo(getLibraryPhotoMarkLabel.snp.top).offset(-4)
            make.centerX.equalToSuperview()
        }
        
        addSubview(xMarkButton)
        xMarkButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(couchMarkGuideLabel.snp.bottom).offset(10)
            make.height.equalTo(46)
            make.width.equalTo(90)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
