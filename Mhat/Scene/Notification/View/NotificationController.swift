//
//  NotificationController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationController: UITableViewController {
    
    // MARK: - Properties
    
    private let viewModel = NotificationViewModel()
        
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .customBlue
        button.setDimensions(width: 32, height: 32)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchNotifications()
        deleteNotificationsCount()
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API
    
    func fetchNotifications() {
        viewModel.fetchNotifications {
            self.tableView.reloadData()
        }
    }
    
    func deleteNotificationsCount() {
        viewModel.deleteNotificationsCount()
    }
        
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar(withTitle: "Notifications", backgroundColor: .white, prefersLargeTitles: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        self.refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc func handleRefresh() {
        fetchNotifications()
        refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.delegate = self
        cell.notification = viewModel.notifications[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.notifications[indexPath.row].user
        let controller = ProfileController()
        controller.viewModel.user = user
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension NotificationController: NotificationCellDelegate {
    func didTapConfirm(_ cell: NotificationCell) {
        viewModel.didTapConfirm(cell) {
            self.tableView.reloadData()
        }
    }
    
    func didTapDelete(_ cell: NotificationCell) {
        viewModel.didTapDelete(cell) {
            self.tableView.reloadData()
        }
    }
}

