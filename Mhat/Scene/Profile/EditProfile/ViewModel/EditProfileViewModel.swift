//
//  EditProfileViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 26.10.22.
//

import UIKit

class EditProfileViewModel {
    
    // MARK: - Properties
    var user = User()
    
    // MARK: - API
    
    func handleSaveButton(profileImage: UIImage, fullname: String, username: String, completion: ((Error?) -> Void)?) {
        AuthService.shared.updateUser(profileImage: profileImage, fullname: fullname, username: username, completion: completion)
    }
}
