//
//  ConfirmCharacterViewController.swift
//  Seldeog
//
//  Created by 권준상 on 2022/03/25.
//

import UIKit

import Lottie
import SnapKit

final class ConfirmCharacterViewController: BaseViewController {
    
    private let shapeImageView = UIImageView()
    private let expressionImageView = UIImageView()
    private let featureImageView = UIImageView()
    private let sayHiLabel = UILabel()
    private let pleaseLoveMeLabel = UILabel()
    private let nextButton = UIButton()
    private let popButton = UIButton()
    private let animationView = Animation.confetti1
    private let popBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setLayouts()
        registerTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAnimation()
    }

    private func registerTarget() {
        [nextButton, popButton].forEach {
            $0.addTarget(self, action: #selector(buttonTapAction(_:)), for: .touchUpInside)
        }
    }

    private func setAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animationView.contentMode = .scaleAspectFill
            self.animationView.frame = self.view.bounds
            self.animationView.play()
            self.animationView.loopMode = .loop
        }
    }
    
    private func registerCharacter() {
        guard let name = CharacterData.nickname else { return }
        let shape = CharacterData.selectedShapeIndex
        let color = CharacterData.selectedColorIndex
        let feature = CharacterData.selectedFeatureIndex
        
        postCharacterInfo(name: name, shape: shape, color: color, feature: feature) { data in
            if data.success {
                CharacterData.myCharacterURLstring = data.data?.usrChrImgDft
                LoginSwitcher.updateRootVC(root: .guide)
            } else {
                self.showToastMessageAlert(message: "캐릭터 생성에 실패하였습니다.")
            }
        }
    }
    
    private func postCharacterInfo(
        name: String,
        shape: Int,
        color: Int,
        feature: Int,
        completion: @escaping (UserResponse) -> Void
    ) {
        UserRepository.shared.postCharacterInfo(name: name, shape: shape, color: color, feature: feature) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? UserResponse else { return }
                completion(data)
            default:
                print("sign in error")
            }
        }
    }
}

extension ConfirmCharacterViewController {
    private func setProperties() {
        view.do {
            $0.backgroundColor = .white
        }
        
        popBarButton.do {
            $0.customView = popButton
            $0.customView?.translatesAutoresizingMaskIntoConstraints = false
            $0.customView?.heightAnchor.constraint(equalToConstant: 35).isActive = true
            $0.customView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        }
        
        navigationItem.do{
            $0.leftBarButtonItem = popBarButton
        }
        
        shapeImageView.do {
            $0.image = CharacterData.selectedColorWithShape
            $0.contentMode = .scaleToFill
        }
        
        expressionImageView.do {
            $0.image = Image.expressionExciting
            $0.contentMode = .scaleToFill
        }
        
        featureImageView.do {
            $0.image = CharacterData.selectedFeature
            $0.contentMode = .scaleToFill
        }
        
        sayHiLabel.do {
            if let nickname = CharacterData.nickname{
                $0.text = "HI! I'M ''\(nickname)''"
            }
            $0.textColor = UIColor.black
            $0.font = .nanumPen(size: 30, family: .bold)
        }
        
        pleaseLoveMeLabel.do {
            $0.text = "PLEASE LOVE ME"
            $0.textColor = UIColor.black
            $0.font = .nanumPen(size: 30, family: .bold)
        }
        
        nextButton.do {
            $0.setTitle("OK", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setBackgroundColor(.black, for: .normal)
            $0.titleLabel?.font = .nanumPen(size: 25, family: .bold)
        }
        
        popButton.do {
            $0.setImage(Image.arrowLeftIcon, for: .normal)
        }
    }
    
    private func setLayouts() {
        setViewHierarchy()
        setConstraints()
    }
    
    private func setViewHierarchy() {
        view.addSubviews(sayHiLabel, pleaseLoveMeLabel, shapeImageView, nextButton, animationView)
        shapeImageView.addSubviews(expressionImageView, featureImageView)
        shapeImageView.bringSubviewToFront(expressionImageView)
        expressionImageView.bringSubviewToFront(featureImageView)
    }
    
    private func setConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        sayHiLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea).offset(120)
            $0.centerX.equalToSuperview()
        }
        
        pleaseLoveMeLabel.snp.makeConstraints {
            $0.top.equalTo(sayHiLabel.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
        }
        
        animationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(animationView.snp.width)
            $0.bottom.equalTo(nextButton.snp.top)
        }
        
        shapeImageView.snp.makeConstraints {
            $0.top.equalTo(pleaseLoveMeLabel.snp.bottom).offset(37)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(290)
        }
        
        expressionImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(290)
        }
        
        featureImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(290)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(safeArea)
            $0.height.equalTo(80)
        }
    }
    
    @objc private func buttonTapAction(_ sender: UIButton) {
        switch sender {
        case nextButton:
            registerCharacter()
        case popButton:
            navigationController?.popViewController(animated: true)
        default:
            return
        }
    }
}
