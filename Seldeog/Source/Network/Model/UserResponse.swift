//
//  UserDetailResponse.swift
//  Seldeog
//
//  Created by 권준상 on 2022/04/07.
//

import Foundation

struct UserResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: UserCharacter?
}

struct UserCharacter: Decodable {
    let usrChrImgDft: String
}
