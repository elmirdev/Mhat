//
//  SearchUserController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 20.06.22.
//

import UIKit

private let reuseIdentifier = "UserCell"

class SearchUserController: UITableViewController {
    
    // MARK: - Properties
    
    let viewModel = SearchUserViewModel()
    
    weak var delegate: ProfileControllerDelegate?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "MainColor")
        button.setDimensions(width: 32, height: 32)
        button.addTarget(self, action: #selector(handleDismissall), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureSearchController()
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissall() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API
    
    func fetchUsers() {
        viewModel.fetchUsers {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar(withTitle: "Search User", backgroundColor: .white, prefersLargeTitles: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "Search"
        definesPresentationContext = false
        navigationItem.searchController = searchController
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .black
            textField.backgroundColor = .white
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchUserController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? viewModel.filteredUsers.count : viewModel.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        cell.user = inSearchMode ? viewModel.filteredUsers[indexPath.row] : viewModel.users[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchUserController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? viewModel.filteredUsers[indexPath.row] : viewModel.users[indexPath.row]
        if user.isCurrentUser {
            let controller = CurrentProfileController()
            controller.viewModel.user = user
            controller.delegate = delegate
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = OtherProfileController()
            controller.viewModel.user = user
            controller.delegate = delegate
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchUserController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        viewModel.filteredUsers = viewModel.users.filter({ user in
            return user.username.contains(searchText)
        })
        self.tableView.reloadData()
    }
}
