//
//  SmsCodeViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 20.10.22.
//

import Foundation
import Firebase

class SmsCodeViewModel {
    
    // MARK: - API
    func verifyCode(smsCode: String, completion: @escaping(Bool)->Void) {
        AuthService.shared.verifyCode(smsCode: smsCode) { success in
            guard success else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Service.shared.checkUserIsRegistered(uid: uid, completion: completion)
        }
    }
}
