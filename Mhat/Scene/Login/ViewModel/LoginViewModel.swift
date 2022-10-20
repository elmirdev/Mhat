//
//  LoginViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 20.10.22.
//

import Foundation

class LoginViewModel {
    
    // MARK: - API
    
    func startAuth(phoneNumber: String, completion: @escaping (Bool)->Void) {
        AuthService.shared.startAuth(phoneNumber: phoneNumber, completion: completion)
    }
}
