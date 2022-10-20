//
//  ChatViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 20.10.22.
//

import Foundation

class ChatViewModel {
    
    // MARK: - Properties
    var user = User()
    var messages = [Message]()
    var fromCurrentUser = false
    
    // MARK: - API
    func fetchMessages(completion: @escaping()->()) {
        
        Service.shared.fetchMessages(forUser: user) { messages in
            self.messages = messages
            completion()
        }
    }
    
    func uploadMesssage(message: String) {
        Service.shared.uploadMessage(message, to: user) { error in
            if let error = error {
                print("DEBUG: Failed to send message with error \(error.localizedDescription)")
                return
            }
        }
    }
}
