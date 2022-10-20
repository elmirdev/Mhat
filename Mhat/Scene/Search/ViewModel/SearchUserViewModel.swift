//
//  SearchUserViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 20.10.22.
//

import Foundation

class SearchUserViewModel {
    
    // MARK: - Properties
    var users = [User]()
    var filteredUsers = [User]()
    
    // MARK: - API
    func fetchUsers(completion: @escaping()->()) {
        //showLoader(true)
        Service.shared.fetchUsers { users in
            //self.showLoader(false)
            self.users = users
            completion()
        }
    }
}
