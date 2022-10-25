//
//  ProfileController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import UIKit
import SDWebImage
import Firebase

protocol ProfileControllerDelegate: AnyObject {
    func handleRemoveFriend(_ user: User)
    func handleLogout()
}

class CurrentProfileController: UIViewController {
    
    // MARK: - Properties
        
    let viewModel = CurrentProfileViewModel()
    
    weak var delegate: ProfileControllerDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "MainColor")
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "arrow.backward", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.setBorder(borderColor: .white, borderWidth: 4)
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
            
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Selectors
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
                
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.register(ProfileOptionCell.self, forCellReuseIdentifier: "profileOptionCell")
                
        profileImageView.setDimensions(width: 200, height: 200)
        profileImageView.layer.cornerRadius = 200 / 2
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
        
        view.addSubview(profileImageView)
        profileImageView.centerX(inView: view)
        profileImageView.anchor(top: containerView.bottomAnchor, paddingTop: -100)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        view.addSubview(stack)
        stack.centerX(inView: profileImageView)
        stack.anchor(top: profileImageView.bottomAnchor, paddingTop: 16)
                
        view.addSubview(tableView)
        tableView.anchor(top: stack.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16)
    }
    
    func configure() {
        guard let url = URL(string: viewModel.user.profileImageUrl) else { return }
        
        profileImageView.sd_setImage(with: url)
        
        fullnameLabel.text = viewModel.user.fullname
        usernameLabel.text = "@\(viewModel.user.username)"
    }
    
    // MARK: - API
    
//    func logout() {
//        let user = viewModel.user
//        
//        if user.isCurrentUser {
//            let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
//            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
//                self.dismiss(animated: true) {
//                    self.delegate?.handleLogout()
//                }
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CurrentProfileController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileMenuOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileOptionCell", for: indexPath) as! ProfileOptionCell
        let option = ProfileMenuOptions(rawValue: indexPath.row)
        cell.option = option
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = EditProfileController()
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CurrentProfileController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - buttonMaker func

extension CurrentProfileController {
    fileprivate func buttonMaker(title: String, titleColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .lightGray
        button.setDimensions(width: 130, height: 44)
        button.layer.cornerRadius = 44 / 3
        return button
    }
}
