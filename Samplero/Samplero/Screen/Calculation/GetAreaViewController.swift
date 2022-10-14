//
//  GetAreaViewController.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/09.
//
import UIKit

import RxCocoa
import RxSwift
final class GetAreaViewController: BottomSheetController {
    
    // MARK: - Properties
    
    var delegate: SaveSizeDelegate?
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        title.text = "시공 면적 입력"
        title.textAlignment = .center
        return title
    }()
    
    let getWidthView = CustomGetSizeView(labelText: "가로")
    let getHeightView = CustomGetSizeView(labelText: "세로")
    
    let separator = UIView()
    
    let textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 50
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.black.cgColor
        stackView.layer.cornerRadius = 6
        return stackView
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        button.isEnabled = false
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .black
        button.backgroundColor = UIColor(hex: "F2F2F7")
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        return button
    }()
    
    var disposeBag = DisposeBag()

     var areaWidth = 0.0
     var areaHeight = 0.0

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        bind()
    }
    
    override func render() {
        textFieldStackView.addArrangedSubview(getWidthView)
        getWidthView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(textFieldStackView)
            make.height.equalTo(48)
        }
        
        textFieldStackView.addArrangedSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(getWidthView.snp.bottom)
            make.height.equalTo(1)
        }
        
        textFieldStackView.addArrangedSubview(getHeightView)
        getHeightView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.height.equalTo(48)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(view).offset(17)
        }
        
        view.addSubview(textFieldStackView)
        textFieldStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
        }
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(17)
            make.top.equalTo(textFieldStackView.snp.bottom).offset(26)
        }
        
    }
    
    override func configUI() {
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.backgroundColor = .systemBackground
    }

    func bind() {
        Observable.combineLatest(getWidthView.textField.rx.text.compactMap({$0}), getHeightView.textField.rx.text.compactMap({$0}))
            .map { width, height in
                if width != "",
                   height != "",
                   let doubleWidth = Double(width),
                   let doubleHeight = Double(height) {
                    self.areaWidth = doubleWidth
                    self.areaHeight = doubleHeight
                    return true }
                return false
            }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: {
                
            })

    }
    
    
    // MARK: - Func

    @objc func buttonDidTap() {
        save()
    }
    
    func save() {
        dismiss(animated: true) {
            self.delegate?.saveButtonTapped(widthString: self.getWidthView.textField.text ?? "", heightString: self.getHeightView.textField.text ?? "")
        }
    }
}

protocol SaveSizeDelegate {
    func saveButtonTapped(widthString: String, heightString: String)
}
