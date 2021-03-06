//
//  PastComplimentViewController.swift
//  Seldeog
//
//  Created by 권준상 on 2022/04/19.
//

import UIKit
import SnapKit
import Kingfisher


final class PastComplimentViewController: BaseViewController {
    
    private let todayLabel = UILabel()
    private let myCharacterImageView = UIImageView()
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
    private var date: String
    
    
    init(date: String) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setLayouts()
        registerTarget()
        getComplimentList(date: date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todayLabel.text = date.toDate().toMonthDay().uppercased()
    }
    
    private func getComplimentList(date: String) {
        
        getPastComplimentList(date: date) { data in
            if data.success {
                let imgURL = URL(string: data.data.usrChrImg)
                do {
                    let data = try Data(contentsOf: imgURL!)
                    self.myCharacterImageView.image = UIImage(data: data)
                } catch { print("image error") }
                self.commentsList = data.data.usrChrCmts
                self.checkImageView.isHidden = !data.data.usrChrCheck
                self.collectionView.reloadData()
            } else {
                self.showToastMessageAlert(message: "칭찬 리스트 로드에 실패하였습니다.")
            }
        }
    }
    
    private func getPastComplimentList(
        date: String,
        completion: @escaping (ComplimentListResponse) -> Void
    ) {
        UserRepository.shared.getUserComplimentList(date: date) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? ComplimentListResponse else { return }
                completion(data)
            default:
                print("API error")
            }
        }
    }
    
    private func registerTarget() {
        [baseTabBarView.calendarButton, baseTabBarView.aboutMeButton, baseTabBarView.selfLoveButton, baseTabBarView.settingButton, dismissButton].forEach {
            $0.addTarget(self, action: #selector(buttonTapAction(_:)), for: .touchUpInside)
        }
    }
    
}

extension PastComplimentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 390, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch commentsList[indexPath.item].usrCmtTags.count {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastComplimentNoTagCell", for: indexPath) as? PastComplimentWithNoTagCell else { return UICollectionViewCell() }
            
            cell.setCellIndex(index: indexPath.item + 1)
            cell.setCompliment(text: commentsList[indexPath.item].usrChrCmt)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastComplimentOneTagCell", for: indexPath) as? PastComplimentWithOneTagCell else { return UICollectionViewCell() }
            
            cell.setCellIndex(index: indexPath.item + 1)
            cell.setCompliment(text: commentsList[indexPath.item].usrChrCmt)
            cell.tag1View.text = commentsList[indexPath.item].usrCmtTags[0]
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastComplimentTwoTagCell", for: indexPath) as? PastComplimentWithTwoTagCell else { return UICollectionViewCell() }
            
            cell.setCellIndex(index: indexPath.item + 1)
            cell.setCompliment(text: commentsList[indexPath.item].usrChrCmt)
            cell.tag1View.text = commentsList[indexPath.item].usrCmtTags[0]
            cell.tag2View.text = commentsList[indexPath.item].usrCmtTags[1]
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }

}

extension PastComplimentViewController {
    
    private func setProperties() {
        
        view.do {
            $0.backgroundColor = .white
        }
        
        navigationItem.do {
            $0.hidesBackButton = true
            $0.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
        }
        
        todayLabel.do {
            $0.font = .nanumPen(size: 35, family: .bold)
            $0.textColor = .black
        }
        
        checkImageView.do {
            $0.image = Image.greenCheck
            $0.isHidden = true
        }
        
        lineView.do {
            $0.image = Image.gradientLine
        }
        
        collectionView.do {
            $0.backgroundColor = .white
            $0.register(PastComplimentWithNoTagCell.self, forCellWithReuseIdentifier: "PastComplimentNoTagCell")
            $0.register(PastComplimentWithOneTagCell.self, forCellWithReuseIdentifier: "PastComplimentOneTagCell")
            $0.register(PastComplimentWithTwoTagCell.self, forCellWithReuseIdentifier: "PastComplimentTwoTagCell")
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
        view.addSubviews(todayLabel, checkImageView, myCharacterImageView, lineView, collectionView, baseTabBarView)
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
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(myCharacterImageView.snp.bottom).offset(20)
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
    
    @objc private func buttonTapAction(_ sender: UIButton) {
        switch sender {
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
