//
//  RegistrationViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 20.10.22.
//

import UIKit.UIImage

class RegistrationViewModel {
    
    // MARK: - API
    
    func handleRegister(profileImage: UIImage, fullname: String, username: String, completion: ((Error?)->Void)?) {
        
        AuthService.shared.createUser(profileImage: profileImage, fullname: fullname, username: username, completion: completion)
    }
}
