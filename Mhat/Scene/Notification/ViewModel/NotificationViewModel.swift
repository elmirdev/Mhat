//
//  NotificationViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 19.10.22.
//

import Foundation

class NotificationViewModel {
    
    // MARK: - Properties
    
    var notifications = [Notification]()
    
    // MARK: - API

    func fetchNotifications(completion: @escaping()->()) {
        NotificationService.shared.fetchNotifications { notifications in
            self.notifications = notifications
            completion()
        }
    }
    
    func deleteNotificationsCount() {
        NotificationService.shared.deleteNotificationsCount { error in
            if error != nil {
                print("DEBUG: Delete notifications count error")
            }
        }
    }
    
    func didTapConfirm(_ cell: NotificationCell, completion: @escaping()->()) {
        guard let user = cell.notification?.user else { return }
        
        Service.shared.confirmRequest(uid: user.uid) { error in
            if error == nil {
                self.fetchNotifications {
                    //
                }
                if self.notifications.count == 1 {
                    self.notifications.removeAll()
                    completion()
                }
            }
        }
    }
    
    func didTapDelete(_ cell: NotificationCell, completion: @escaping()->()) {
        guard let user = cell.notification?.user else { return }
        
        Service.shared.deleteRequest(uid: user.uid) { error in
            if error == nil {
                self.fetchNotifications {
                    //
                }
                if self.notifications.count == 1 {
                    self.notifications.removeAll()
                    completion()
                }
            }
        }
    }
}
