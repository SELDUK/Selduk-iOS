//
//  TodayComplimentViewController.swift
//  Seldeog
//
//  Created by 권준상 on 2022/04/12.
//

import UIKit
import SnapKit
import Kingfisher

protocol CommentButtonProtocol {
    func modifyComment(serverIndex: Int, cellIndex: Int)
    func deleteComment(index: Int)
}

final class TodayComplimentViewController: BaseViewController {
    
    private let todayLabel = UILabel()
    private let myCharacterImageView = UIImageView()
    private let writeButton = UIButton()
    private let lineView = UIImageView()
    private let dismissButton = UIButton()
    private let checkImageView = UIImageView()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), collectionViewLayout: layout)
        return cv
    }()
    private let baseTabBarView = BaseTabBarView()
    private var commentsList: [UserCharacterComment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setLayouts()
        registerTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let today = Date()
        todayLabel.text = today.toMonthDay().uppercased()
        getComplimentList()
    }
    
    private func getComplimentList() {
        let today = Date()
        
        getTodayComplimentList(date: today.toString()) { data in
            if data.success {
                let imgURL = URL(string: data.data.usrChrImg)
                do {
                    let data = try Data(contentsOf: imgURL!)
                    self.myCharacterImageView.image = UIImage(data: data)
                } catch { print("image error") }
                CharacterData.characterIndex = data.data.usrChrIdx
                self.commentsList = data.data.usrChrCmts
                self.checkImageView.isHidden = !data.data.usrChrCheck
                self.collectionView.reloadData()
            } else {
                self.showToastMessageAlert(message: "칭찬 리스트 로드에 실패하였습니다.")
            }
        }
    }
    
    private func getTodayComplimentList(
        date: String,
        completion: @escaping (ComplimentListResponse) -> Void
    ) {
        print(date)
        UserRepository.shared.getUserComplimentList(date: date) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? ComplimentListResponse else { return }
                completion(data)
            default:
                print("sign in error")
            }
        }
    }
    
    private func deleteCommentIndex(usrChrCmtIdx: Int) {
        if let index = CharacterData.characterIndex {
            deleteComment(usrChrIdx: index, usrChrCmtIdx: usrChrCmtIdx) { data in
                if data.success {
                    self.getComplimentList()
                } else {
                    self.showToastMessageAlert(message: "코멘트 작성에 실패하였습니다.")
                }
            }
        }
    }
    
    private func deleteComment(
        usrChrIdx: Int,
        usrChrCmtIdx: Int,
        completion: @escaping (UserResponse) -> Void
    ) {
        UserRepository.shared.deleteComment(usrChrIdx: usrChrIdx, usrChrCmtIdx: usrChrCmtIdx) { result in
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
    
    private func registerTarget() {
        [writeButton, baseTabBarView.calendarButton, baseTabBarView.aboutMeButton, baseTabBarView.selfLoveButton, baseTabBarView.settingButton, dismissButton].forEach {
            $0.addTarget(self, action: #selector(buttonTapAction(_:)), for: .touchUpInside)
        }
    }
    
}

extension TodayComplimentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CommentButtonProtocol {
    
    func modifyComment(serverIndex: Int, cellIndex: Int) {
        var tag1 = ""
        var tag2 = ""
        switch commentsList[cellIndex - 1].usrCmtTags.count {
        case 1:
            tag1 = commentsList[cellIndex - 1].usrCmtTags[0]
        case 2:
            tag1 = commentsList[cellIndex - 1].usrCmtTags[0]
            tag2 = commentsList[cellIndex - 1].usrCmtTags[1]
        default:
            tag1 = ""
            tag2 = ""
        }
        
        let modifyComplimentViewController = ModifyComplimentViewController(previousComment: commentsList[cellIndex-1].usrChrCmt, previousTag1: tag1, previousTag2: tag2, commentIndex: serverIndex)
        navigationController?.pushViewController(modifyComplimentViewController, animated: false)
        
    }
    
    func deleteComment(index: Int) {
        setAlertConfirmAndCancel(index: index, message: "삭제된 칭찬은 복구되지 않습니다. 칭찬을 정말 삭제하시겠습니까?")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 390, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch commentsList[indexPath.item].usrCmtTags.count {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComplimentNoTagCell", for: indexPath) as? ComplimentWithNoTagCell else { return UICollectionViewCell() }
            
            cell.setCellIndex(index: indexPath.item + 1)
            cell.setCompliment(text: commentsList[indexPath.item].usrChrCmt)
            cell.setCommentIndex(index: commentsList[indexPath.item].usrChrCmtIdx)
            cell.buttonDelegate = self
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComplimentOneTagCell", for: indexPath) as? ComplimentWithOneTagCell else { return UICollectionViewCell() }
            
            cell.setCellIndex(index: indexPath.item + 1)
            cell.setCompliment(text: commentsList[indexPath.item].usrChrCmt)
            cell.setCommentIndex(index: commentsList[indexPath.item].usrChrCmtIdx)
            cell.tag1View.text = commentsList[indexPath.item].usrCmtTags[0]
            cell.buttonDelegate = self
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComplimentTwoTagCell", for: indexPath) as? ComplimentWithTwoTagCell else { return UICollectionViewCell() }
            
            cell.setCellIndex(index: indexPath.item + 1)
            cell.setCompliment(text: commentsList[indexPath.item].usrChrCmt)
            cell.setCommentIndex(index: commentsList[indexPath.item].usrChrCmtIdx)
            cell.tag1View.text = commentsList[indexPath.item].usrCmtTags[0]
            cell.tag2View.text = commentsList[indexPath.item].usrCmtTags[1]
            cell.buttonDelegate = self
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }

}

extension TodayComplimentViewController {
    
    private func setProperties() {
        
        view.do {
            $0.backgroundColor = .white
        }
        
        navigationItem.do {
            $0.hidesBackButton = true
            $0.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
        }
        
        todayLabel.do {
            $0.textColor = .black
            $0.font = .nanumPen(size: 35, family: .bold)
        }
        
        checkImageView.do {
            $0.image = Image.greenCheck
            $0.isHidden = true
        }
        
        writeButton.do {
            $0.setBackgroundColor(.black, for: .normal)
            $0.setImage(UIImage(systemName: "plus"), for: .normal)
            $0.tintColor = .white
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 25
        }
        
        lineView.do {
            $0.image = Image.gradientLine
        }
        
        collectionView.do {
            $0.backgroundColor = .white
            $0.register(ComplimentWithNoTagCell.self, forCellWithReuseIdentifier: "ComplimentNoTagCell")
            $0.register(ComplimentWithOneTagCell.self, forCellWithReuseIdentifier: "ComplimentOneTagCell")
            $0.register(ComplimentWithTwoTagCell.self, forCellWithReuseIdentifier: "ComplimentTwoTagCell")
            $0.delegate = self
            $0.dataSource = self
            $0.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            $0.showsHorizontalScrollIndicator = false
            $0.isScrollEnabled = true
        }
        
        baseTabBarView.calendarButton.do {
            $0.setImage(Image.calendarIconClicked, for: .normal)
            $0.setTitleColor(.white, for: .normal)
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
        view.addSubviews(todayLabel, checkImageView, myCharacterImageView, writeButton, lineView, collectionView, baseTabBarView)
    }
    
    private func setConstraints() {
        todayLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints {
            $0.centerY.equalTo(todayLabel)
            $0.leading.equalTo(todayLabel.snp.trailing).offset(10)
            $0.width.equalTo(34)
            $0.height.equalTo(32)
        }
        
        myCharacterImageView.snp.makeConstraints {
            $0.top.equalTo(todayLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(250)
            $0.height.equalTo(250)
        }
        
        writeButton.snp.makeConstraints {
            $0.top.equalTo(myCharacterImageView.snp.bottom).offset(-20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(50)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(writeButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(7)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(baseTabBarView.snp.top)
        }
        
        baseTabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
        
    }
    
    private func setAlertConfirmAndCancel(index: Int, message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.deleteCommentIndex(usrChrCmtIdx: index)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @objc private func buttonTapAction(_ sender: UIButton) {
        switch sender {
        case writeButton:
            navigationController?.pushViewController(WriteComplimentViewController(), animated: false)
        case baseTabBarView.calendarButton, dismissButton:
            navigationController?.popViewController(animated: false)
        case baseTabBarView.aboutMeButton:
            LoginSwitcher.updateRootVC(root: .aboutMe)
        case baseTabBarView.selfLoveButton:
            LoginSwitcher.updateRootVC(root: .selfLove)
        case baseTabBarView.settingButton:
            LoginSwitcher.updateRootVC(root: .setting)
        default:
            return
        }
    }
    
}
