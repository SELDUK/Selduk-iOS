//
//  MakeCharacterViewCell.swift
//  Seldeog
//
//  Created by 권준상 on 2022/03/20.
//

import UIKit

class MakeCharacterViewCell: UICollectionViewCell {
    
    let cellImageView = UIImageView()

    public func setImage(image: UIImage) {
        cellImageView.image = image
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setProperties()
        setLayouts()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setProperties() {
        cellImageView.do {
            $0.contentMode = .scaleToFill
        }
    }

    private func setLayouts() {
        setViewHierarchy()
        setConstraints()
    }

    private func setViewHierarchy() {
        contentView.addSubview(cellImageView)
    }

    private func setConstraints() {
        cellImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(100)
        }
    }
}
