//
//  WriteFeature.swift
//  Seldeog
//
//  Created by 권준상 on 2022/04/20.
//

import UIKit

import SnapKit

final class WriteFeatureViewController: BaseViewController {
    
    private let commentLabel = UILabel()
    private let commentTextView = UITextView()
    private let wordCountLabel = UILabel()
    private let registerButton = UIButton()
    private let popButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.title = ""
    }
    
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }
    
    private func postFeature(content: String) {
        postFeature(content: content) { data in
            if data.success {
                self.navigationController?.popViewController(animated: false)
            } else {
                self.showToastMessageAlert(message: "ABOUT ME 작성에 실패하였습니다.")
            }
        }
    }
    
    private func postFeature(
        content: String,
        completion: @escaping (UserResponse) -> Void
    ) {
        UserRepository.shared.postFeature(content: content) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? UserResponse else { return }
                completion(data)
            default:
                print("API error")
            }
        }
    }
    
}

extension WriteFeatureViewController {
    
    private func setProperties() {
        
        view.backgroundColor = .white
        
        navigationItem.do {
            $0.setLeftBarButtonItems([UIBarButtonItem(customView: popButton)], animated: false)
        }

        commentLabel.do {
            $0.text = "COMMENT"
            $0.textColor = .black
            $0.font = .nanumPen(size: 35, family: .bold)
        }
        
        commentTextView.do {
            $0.delegate = self
            $0.text = "칭찬을 작성해주세요"
            $0.backgroundColor = .white
            $0.textColor = UIColor.lightGray
            $0.font = .nanumPen(size: 15, family: .bold)
            $0.isScrollEnabled = false
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.black.cgColor
        }
        
        wordCountLabel.do {
            $0.textColor = .black
            $0.text = "0/50자"
            $0.font = .nanumPen(size: 11, family: .bold)
        }
        
        registerButton.do {
            $0.backgroundColor = .black
            $0.setTitle("OK", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .nanumPen(size: 30, family: .bold)
            $0.addTarget(self, action: #selector(buttonTapAction(_:)), for: .touchUpInside)
        }
        
        popButton.do {
            $0.setImage(Image.arrowLeftIcon, for: .normal)
            $0.addTarget(self, action: #selector(buttonTapAction(_:)), for: .touchUpInside)
        }
    }
    
    private func setLayouts() {
        setViewHierarchy()
        setConstraints()
    }
    
    private func setViewHierarchy() {
        view.addSubviews(commentLabel, commentTextView, wordCountLabel, registerButton)
    }
    
    private func setConstraints() {
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
        }
        
        commentTextView.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(170)
        }
        
        wordCountLabel.snp.makeConstraints {
            $0.trailing.equalTo(commentTextView.snp.trailing).offset(-11)
            $0.bottom.equalTo(commentTextView.snp.bottom).offset(-10)
        }
        
        registerButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
            $0.bottom.equalToSuperview()
        }
    }

    
    @objc private func buttonTapAction(_ sender: UIButton) {
        switch sender {
        case registerButton:
            
            var commentTrimText = ""
            
            if (commentTextView.textColor == UIColor.lightGray) || commentTextView.text.count == 0 {
                self.showToastMessageAlert(message: "칭찬을 작성해주세요")
                return
            } else {
                commentTrimText = commentTextView.text.trimmingCharacters(in: .whitespaces)
            }
            
            postFeature(content: commentTrimText)
        case popButton:
            self.setAlertConfirmAndCancel(message: "해당 페이지를 벗어나면 작성 중인 내용이 저장되지 않습니다. 정말 나가시겠습니까?")
        default:
            return
        }
    }
}

extension WriteFeatureViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
      if commentTextView.textColor == UIColor.lightGray {
          commentTextView.text = nil
          commentTextView.textColor = UIColor.black
      }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
      if commentTextView.text.isEmpty {
        commentTextView.text = "칭찬을 작성해주세요"
        commentTextView.textColor = UIColor.lightGray
      }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        wordCountLabel.text = "\(changedText.count)/90자"
        return changedText.count <= 89
    }
}
