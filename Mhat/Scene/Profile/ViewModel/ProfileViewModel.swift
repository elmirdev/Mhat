//
//  ProfileViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import Foundation
import UIKit

class ProfileViewModel {
    
    var user = User()
    
    // MARK: - Returned Datas
    var editProfileAddFriendButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }

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
        if user.isCurrentUser {
            return "Logout"
        }
        
        if !user.isCurrentUser {
            return "Message"
        }
        
        return "Loading"
    }
    
    var shouldShowMessageButton: Bool {
        return !user.isFriend ? true : false
    }
    
    var messageLogoutButtonColor: UIColor {
        return user.isCurrentUser ? .systemRed : .lightGray
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
