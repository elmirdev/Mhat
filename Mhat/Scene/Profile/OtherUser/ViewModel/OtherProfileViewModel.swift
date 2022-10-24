//
//  OtherProfileViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 24.10.22.
//

import UIKit

class OtherProfileViewModel {
    
    var user = User()
    
    // MARK: - Returned Datas
    var addFriendButtonTitle: String {

        if !user.isFriend && !user.isRequested {
            return "Add Friend"
        }
        
        if user.isFriend && !user.isCurrentUser {
            return "Friend"
        }
        
        if user.isRequested && !user.isFriend && !user.isCurrentUser {
            return "Requested"
        }
        
        return "Loading"
    }
    
    var messageLogoutButtonTitle: String {
        
        if !user.isCurrentUser {
            return "Message"
        }
        
        return "Loading"
    }
    
    var shouldShowMessageButton: Bool {
        return !user.isFriend ? true : false
    }
    
    var messageButtonColor: UIColor {
        return .systemGray2
    }
    
    // MARK: - Funcs
    func checkUserIsFriendOrIsRequest(completion: @escaping(()->())) {
        Service.shared.checkUserIsFriend(uid: user.uid) { isFriend in
            self.user.isFriend = isFriend
            NotificationService.shared.checkUserIsRequested(uid: self.user.uid) { isRequested in
                self.user.isRequested = isRequested
                completion()
            }
        }
    }
}
