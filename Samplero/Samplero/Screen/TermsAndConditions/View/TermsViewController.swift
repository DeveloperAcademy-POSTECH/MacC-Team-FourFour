//
//  TermsViewController.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/11.
//

import UIKit

import SnapKit

private enum Size {
    static let termsViewInsetPadding = 20
    static let checkboxSize = 20
    static let topOffset = 28
    static let spaceAfterCheckbox = 16
    static let containerBottomOffset = 40
    static let linkToKakaoButtonHeight = 64
    static let linkToKakaoButtonRadius = 14.0
    static let buttonLabelAlphaValue = 0.6
    static let checkboxCornerRadius = 5.0
    static let checkboxBorderWidth = 1.0
    static let termsContentsInset = UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)
}

class TermsViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "샘플 발송을 위해 약관동의가 필요합니다."
        label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
        label.textAlignment = .left
        return label
    }()
    
    private let termsContents: UITextView = {
        let textView = UITextView()
        textView.text = """
        [개인 정보 수집 및 이용 동의 안내]
        
        샘플로는 '시공매트 샘플 배송'을 위하여 다음과 같이 개인정보를 수집 및 이용합니다.
        수집한 개인 정보는 배송 이외의 목적으로는 사용하지 않으며, 배송 완료 시점을 기준으로 1개월 간 보관 후 파기됩니다.
        개인 정보의 수집 및 이용에 대한 동의를 거부하실 수 있으나 이 경우 시공매트 샘플 배송이 불가합니다.
        
        1. 수집 항목: [필수] 성함, 휴대폰 연락처, 배송 주소
        2. 수집 이용 목적: 시공매트 샘플 배송
        3. 이용 및 보유 기간: 배송 완료 후 1개월
        """
        textView.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
        textView.textAlignment = .left
        textView.isEditable = false
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = Size.termsContentsInset
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let checkboxImageView = CustomCheckbox(isChecked: false)
    
    private let checkboxLabel: UILabel = {
        let label = UILabel()
        label.text = "약관에 동의합니다."
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
        return label
    }()
    
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.text = "이후 과정은 카카오톡 채팅에서 진행됩니다."
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
        label.textAlignment = .center
        label.tintColor = .secondaryLabel
        label.alpha = Size.buttonLabelAlphaValue
        return label
    }()
    
    private let linkToKakaoButton: UIButton = {
        let button = UIButton()
        button.setTitle("카카오톡 채팅 연결", for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = Size.linkToKakaoButtonRadius
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        button.tintColor = .white
        button.addTarget(self, action: #selector(sendAlert), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Life Cycle
    
    override func render() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Size.topOffset)
            make.leading.trailing.equalToSuperview().inset(Size.termsViewInsetPadding)
        }
        
        view.addSubview(termsContents)
        termsContents.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.termsViewInsetPadding)
            make.leading.trailing.equalToSuperview().inset(Size.termsViewInsetPadding)
        }
        
        let checkView = UIView()
        view.addSubview(checkView)
        checkView.snp.makeConstraints { make in
            make.top.equalTo(termsContents.snp.bottom).offset(Size.topOffset)
            make.leading.trailing.equalToSuperview().inset(Size.termsViewInsetPadding)
            make.height.equalTo(Size.checkboxSize)
        }
        checkView.addSubview(checkboxImageView)
        checkboxImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Size.checkboxSize)
            make.leading.equalToSuperview()
        }
        checkView.addSubview(checkboxLabel)
        checkboxLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkboxImageView.snp.trailing).offset(Size.spaceAfterCheckbox)
        }
        
        view.addSubview(linkToKakaoButton)
        linkToKakaoButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Size.termsViewInsetPadding)
            make.bottom.equalToSuperview().inset(Size.containerBottomOffset)
            make.height.equalTo(Size.linkToKakaoButtonHeight)
        }
        
        view.addSubview(buttonLabel)
        buttonLabel.snp.makeConstraints { make in
            make.bottom.equalTo(linkToKakaoButton.snp.top).offset(-8)   // 마이너스만 동작..
            make.leading.trailing.equalToSuperview()
        }
    }

    
    // MARK: - Func
    
    @objc func sendAlert() {
//        makeAlert(title: "알림", message: "약관에 동의하지 않으면 샘플을 주문할 수 없어요.")
    }
}
