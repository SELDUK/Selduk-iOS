//
//  SignUpController.swift
//  Seldeog
//
//  Created by 권준상 on 2022/03/02.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class SignUpViewController: BaseViewController {
    
    private let signUpLabel = UILabel()
    private let idImageView = UIImageView()
    private let idTextField = UITextField()
    private let idTextFieldLineView = UIView()
    private let checkExistenceButton = UIButton()
    private let passwordImageView = UIImageView()
    private let passwordTextField = UITextField()
    private let passwordTextFieldLineView = UIView()
    private let checkPasswordValidView = UIImageView()
    private let passwordConfirmImageView = UIImageView()
    private let passwordConfirmTextField = UITextField()
    private let passwordConfirmTextFieldLineView = UIView()
    private let checkPasswordSameView = UIImageView()
    private let signUpButton = UIButton()
    private let signInContainerView = UIView()
    private let signInLabel = UILabel()
    private let signInLineView = UIView()
    private let signInButton = UIButton()
    private let dismissButton = UIButton()
    private let copyRightLabel = UILabel()
    private let attributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        NSAttributedString.Key.font : UIFont.nanumPen(size: 20, family: .bold)
    ]

    private let disposeBag = DisposeBag()
    
    private var isIDValid: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setLayouts()
        registerTarget()
        checkValidate()
    }
    
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }
    
    private func registerTarget() {
        [checkExistenceButton, signUpButton, dismissButton, signInButton].forEach {
            $0.addTarget(self, action: #selector(buttonTapAction(_:)), for: .touchUpInside)
        }
    }
    
    private func checkValidate() {
        let idText = idTextField.rx.text.orEmpty.distinctUntilChanged()
        let passwordText = passwordTextField.rx.text.orEmpty.distinctUntilChanged()
        let passwordConfirmText = passwordConfirmTextField.rx.text.orEmpty.distinctUntilChanged()
        let isPasswordValid = PublishRelay<Bool>()
        let isPasswordSame = PublishRelay<Bool>()
        
        idText
            .map { !$0.isEmpty }
            .bind { [weak self] isActive in
                self?.isIDValid = false
                self?.checkExistenceButton.isEnabled = isActive
            }
            .disposed(by: disposeBag)
        
        passwordText
            .map { [weak self] text in
                self?.validatePassword(text: text) ?? false
            }
            .bind { [weak self] bool in
                if bool {
                    self?.checkPasswordValidView.image = Image.validIcon
                    isPasswordValid.accept(true)
                } else {
                    self?.checkPasswordValidView.image = Image.invalidIcon
                    isPasswordValid.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(passwordText, passwordConfirmText)
            .skip(1)
            .map { [weak self] password, passwordConfirm -> Bool in
                guard let self = self else { return false }
                return password == passwordConfirm && self.validatePassword(text: passwordConfirm)
            }
            .bind { [weak self] bool in
                if bool {
                    self?.checkPasswordSameView.image = Image.validIcon
                    isPasswordSame.accept(true)
                } else {
                    self?.checkPasswordSameView.image = Image.invalidIcon
                    isPasswordSame.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isPasswordValid, isPasswordSame)
            .map { $0 && $1 }
            .subscribe { [weak self] isActivate in
                self?.signUpButton.isEnabled = isActivate
            }
            .disposed(by: disposeBag)
    }
    
    private func validatePassword(text: String) -> Bool {
        if text.count < 8 {
            return false
        } else {
            return true
        }
    }
    
    private func checkExistence() {
        guard let id = self.idTextField.text else { return }
        checkIDValid(id: id) { data in
            if data.success {
                self.isIDValid = true
                self.showToastMessageAlert(message: data.message)
            } else {
                self.showToastMessageAlert(message: data.message)
            }
        }
    }
    
    private func signUp() {
        guard let id = self.idTextField.text else { return }
        guard let password = self.passwordTextField.text else { return }
        
        postSignUp(id: id, password: password) { data in
            if data.success {
                self.setAlertAndFinish(message: "회원가입 완료!!")
            } else {
                self.showToastMessageAlert(message: "회원가입에 실패하였습니다.")
            }
        }
    }

    private func checkIDValid(
        id: String,
        completion: @escaping (AuthResponse) -> Void
    ) {
        AuthRepository.shared.checkIDValid(id: id) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? AuthResponse else { return }
                completion(data)
            default:
                print("check mail error")
            }
        }
    }

    private func postSignUp(
        id: String,
        password: String,
        completion: @escaping (AuthResponse) -> Void
    ) {
        AuthRepository.shared.postSignUp(id: id,
                                         password: password) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? AuthResponse else { return }
                completion(data)
            default:
                print("sign up error")
            }
        }
    }

}

extension SignUpViewController {
    
    private func setProperties() {
        view.do {
            $0.backgroundColor = .white
        }
        
        navigationController?.do {
            $0.isNavigationBarHidden = false
            let dismissBarButton = UIBarButtonItem(customView: dismissButton)
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.rightBarButtonItem = dismissBarButton
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        
        signUpLabel.do {
            $0.text = "SIGN UP"
            $0.textColor = .black
            $0.font = .nanumPen(size: 35, family: .bold)
        }
        
        idImageView.do {
            $0.image = Image.userIcon
        }
        
        idTextField.do {
            $0.textColor = .black
            $0.attributedPlaceholder = NSAttributedString(string: "ID", attributes: attributes)
            $0.clearButtonMode = .never
            $0.keyboardType = .alphabet
            $0.layer.borderWidth = 0
            $0.addLeftPadding()
            $0.autocapitalizationType = .none
        }
        
        checkExistenceButton.do {
            $0.setImage(Image.checkButtonRepeat, for: .normal)
        }

        idTextFieldLineView.do {
            $0.backgroundColor = .black
        }

        passwordImageView.do {
            $0.image = Image.lockIcon
        }
        
        passwordTextField.do {
            $0.textColor = .black
            $0.attributedPlaceholder = NSAttributedString(string: "PASSWORD (8자리 이상)", attributes: attributes)
            $0.isSecureTextEntry = true
            $0.clearButtonMode = .never
            $0.keyboardType = .asciiCapable
            $0.layer.borderWidth = 0
            $0.addLeftPadding()
            $0.autocapitalizationType = .none
        }
        
        passwordTextFieldLineView.do {
            $0.backgroundColor = .black
        }
        
        checkPasswordValidView.do {
            $0.image = Image.invalidIcon
        }
        
        passwordConfirmImageView.do {
            $0.image = Image.checkPasswordIcon
        }
        
        passwordConfirmTextField.do {
            $0.textColor = .black
            $0.attributedPlaceholder = NSAttributedString(string: "CONFIRM PASSWORD", attributes: attributes)
            $0.isSecureTextEntry = true
            $0.clearButtonMode = .never
            $0.keyboardType = .asciiCapable
            $0.layer.borderWidth = 0
            $0.addLeftPadding()
            $0.autocapitalizationType = .none
        }
        
        passwordConfirmTextFieldLineView.do {
            $0.backgroundColor = .black
        }
        
        checkPasswordSameView.do {
            $0.image = Image.invalidIcon
        }

        signUpButton.do {
            $0.setTitle("SIGN UP", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .nanumPen(size: 20, family: .bold)
            $0.setBackgroundColor(.black, for: .normal)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 5
            $0.isEnabled = false
        }
        
        signInLabel.do {
            $0.text = "HAVE AN ACCOUNT?"
            $0.font = .nanumPen(size: 13, family: .bold)
            $0.textColor = UIColor.colorWithRGBHex(hex: 0xAAAAAA)
        }
        
        signInLineView.do {
            $0.backgroundColor = UIColor.colorWithRGBHex(hex: 0xAAAAAA)
        }
        
        signInButton.do {
            $0.setTitle("SIGN IN", for: .normal)
            $0.setTitleColor(UIColor.colorWithRGBHex(hex: 0x005982), for: .normal)
            $0.titleLabel?.font = .nanumPen(size: 15, family: .bold)
        }
        
        copyRightLabel.do {
            $0.text = "Copyright 2022. KGB Co., Ltd. all rights reserved."
            $0.textColor = .black
            $0.font = .nanumPen(size: 10, family: .regular)
        }
        
        dismissButton.do {
            $0.setImage(Image.xLineIcon, for: .normal)
        }
    }
    
    private func setLayouts() {
        setViewHierarchy()
        setConstraints()
    }
    
    private func setViewHierarchy() {
        view.addSubviews(signUpLabel, idImageView, idTextField, idTextFieldLineView, checkExistenceButton, passwordImageView, passwordTextField, passwordTextFieldLineView, checkPasswordValidView, passwordConfirmImageView, passwordConfirmTextField, passwordConfirmTextFieldLineView, checkPasswordSameView, signUpButton, signInContainerView, copyRightLabel)
        signInContainerView.addSubviews(signInLabel, signInLineView, signInButton)
    }
    
    private func setConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        signUpLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea).offset(24)
            $0.centerX.equalToSuperview()
        }
        
        idImageView.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(82)
            $0.leading.equalToSuperview().inset(30)
            $0.width.height.equalTo(25)
        }

        idTextField.snp.makeConstraints {
            $0.centerY.equalTo(idImageView)
            $0.leading.equalTo(idImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(checkExistenceButton.snp.leading).offset(-10)
            $0.height.equalTo(40)
        }
        
        idTextFieldLineView.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(1)
        }

        checkExistenceButton.snp.makeConstraints {
            $0.centerY.equalTo(idTextField)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(50)
            $0.height.equalTo(23)
        }

        passwordImageView.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(34)
            $0.leading.equalToSuperview().inset(30)
            $0.width.equalTo(21)
            $0.height.equalTo(27)
        }

        passwordTextField.snp.makeConstraints {
            $0.centerY.equalTo(passwordImageView)
            $0.leading.equalTo(passwordImageView.snp.trailing).offset(19)
            $0.trailing.equalTo(checkPasswordValidView.snp.leading).offset(-10)
            $0.height.equalTo(40)
        }
        
        passwordTextFieldLineView.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(1)
        }
        
        checkPasswordValidView.snp.makeConstraints {
            $0.centerY.equalTo(passwordTextField)
            $0.trailing.equalToSuperview().offset(-34)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        passwordConfirmImageView.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(35)
            $0.leading.equalToSuperview().inset(30)
            $0.width.equalTo(21)
            $0.height.equalTo(26)
        }

        passwordConfirmTextField.snp.makeConstraints {
            $0.centerY.equalTo(passwordConfirmImageView)
            $0.leading.equalTo(passwordConfirmImageView.snp.trailing).offset(20)
            $0.trailing.equalTo(checkPasswordSameView.snp.leading).offset(-10)
            $0.height.equalTo(40)
        }
        
        passwordConfirmTextFieldLineView.snp.makeConstraints {
            $0.top.equalTo(passwordConfirmTextField.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(1)
        }
        
        checkPasswordSameView.snp.makeConstraints {
            $0.centerY.equalTo(passwordConfirmTextField)
            $0.trailing.equalToSuperview().offset(-34)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }

        signUpButton.snp.makeConstraints {
            $0.top.equalTo(checkPasswordSameView.snp.bottom).offset(54)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        signInContainerView.snp.makeConstraints {
            $0.top.equalTo(signUpButton.snp.bottom).offset(29)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(15)
        }
        
        signInLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        signInLineView.snp.makeConstraints {
            $0.leading.equalTo(signInLabel.snp.trailing).offset(9)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(14)
        }
        
        signInButton.snp.makeConstraints {
            $0.leading.equalTo(signInLineView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        copyRightLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeArea).offset(-67)
        }
    }
    
    @objc private func buttonTapAction(_ sender: UIButton) {
        switch sender {
        case checkExistenceButton:
            checkExistence()
        case signUpButton:
            isIDValid ? signUp() : setAlert(message: "아이디 중복확인을 완료하세요.")
        case dismissButton:
            dismiss(animated: true, completion: nil)
        case signInButton:
            navigationController?.pushViewController(SignInViewController(), animated: false)
        default:
            return
        }
    }
}
