//
//  OtherProfileController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 24.10.22.
//

import UIKit

class OtherProfileController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel = OtherProfileViewModel()
    
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
        iv.backgroundColor = .systemGray4
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
    
    private lazy var addFriendButton: UIButton = {
        let button = buttonMaker(title: "Loading", titleColor: .white)
        button.addTarget(self, action: #selector(handleAddFirend), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageButton: UIButton = {
        let button = buttonMaker(title: "Loading", titleColor: .white)
        button.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        return button
    }()

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureUI()
        checkUserIsFriendOrIsRequest()
    }
    
    // MARK: - Selectors
    
    @objc func handleAddFirend() {
        let user = viewModel.user
        if user.isFriend && !user.isCurrentUser {
            let alert = UIAlertController(title: nil, message: "Are you sure you want to remove from friends?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Remove from Friends", style: .destructive, handler: { _ in
                self.dismiss(animated: true) {
                    self.delegate?.handleRemoveFriend(user)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }

        if !user.isCurrentUser && !user.isRequested && !user.isFriend {
            NotificationService.shared.uploadNotification(uid: user.uid) { error in
                if let error = error {
                    print("DEBUG: Error is \(error.localizedDescription)")
                    return
                }
                self.viewModel.user.isRequested = true
                self.configureAfterDataFetched()
            }
        }
    }
    
    @objc func handleMessage() {
        let user = viewModel.user
        
        let controller = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.viewModel.user = user
        navigationController?.pushViewController(controller, animated: true)
    }

    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API
    
    func checkUserIsFriendOrIsRequest() {
        viewModel.checkUserIsFriendOrIsRequest {
            self.configureAfterDataFetched()
        }
    }

    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
                        
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
        
        let buttonStack = UIStackView(arrangedSubviews: [addFriendButton, messageButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        
        view.addSubview(buttonStack)
        buttonStack.centerX(inView: profileImageView, topAnchor: stack.bottomAnchor, paddingTop: 16)
        buttonStack.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
    }
    
    func configure() {
        guard let url = URL(string: viewModel.user.profileImageUrl) else { return }
        
        profileImageView.sd_setImage(with: url)
        
        fullnameLabel.text = viewModel.user.fullname
        usernameLabel.text = "@\(viewModel.user.username)"
    }
    
    func configureAfterDataFetched() {
        messageButton.isHidden = viewModel.shouldShowMessageButton
        messageButton.setTitle(viewModel.messageLogoutButtonTitle, for: .normal)
        messageButton.backgroundColor = viewModel.messageButtonColor
        
        addFriendButton.setTitle(viewModel.addFriendButtonTitle, for: .normal)
        addFriendButton.backgroundColor = UIColor(named: "MainColor")
    }
}

// MARK: - UIGestureRecognizerDelegate

extension OtherProfileController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


// MARK: - buttonMaker func

extension OtherProfileController {
    fileprivate func buttonMaker(title: String, titleColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemGray4
        button.setDimensions(width: 130, height: 44)
        button.layer.cornerRadius = 44 / 3
        return button
    }
}
