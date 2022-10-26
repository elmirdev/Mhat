//
//  EditProfileController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 25.10.22.
//

import UIKit

class EditProfileController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel = EditProfileViewModel()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "arrow.backward", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "MainColor")
        
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        return button
    }()
    
    private let barTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(named: "MainColor")
        label.text = "Edit Profile"
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.setBorder(borderColor: UIColor(named: "MainColor")!, borderWidth: 4)
        iv.backgroundColor = .systemGray4
        return iv
    }()
    
    private var newProfileImage: UIImage?
    
    private lazy var changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "camera.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "MainColor")
        button.backgroundColor = .white
        button.setDimensions(width: 48, height: 48)
        button.layer.cornerRadius = 48 / 2
        button.addTarget(self, action: #selector(handleChangePhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var fullnameContainerView = InputContainerView(textField: fullnameTextField, shouldHideLabelFlag: true)
    private lazy var usernameContainerView = InputContainerView(textField: usernameTextField, shouldHideLabelFlag: true)
    
    private let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fullname"
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "MainColor")
        button.setHeight(height: 48)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = .white
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configure()
    }
    
    // MARK: - Selectors
    
    @objc private func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleChangePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func handleSaveButton() {
        guard let profileImage = profileImageView.image else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        if newProfileImage != nil || usernameTextField.text != viewModel.user.username || fullnameTextField.text != viewModel.user.fullname {
            showLoader(true)
            viewModel.handleSaveButton(profileImage: profileImage, fullname: fullname, username: username) { error in
                if error != nil {
                    self.showAlert(title: "Error", errorMessage: "Something went wrong", completion: nil)
                    self.showLoader(false)
                    return
                }
                self.showLoader(false)
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            showAlert(title: "Error", errorMessage: "You didn't make any changes", completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        profileImageView.setDimensions(width: 200, height: 200)
        profileImageView.layer.cornerRadius = 200 / 2
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
        
        view.addSubview(barTitle)
        barTitle.centerX(inView: view)
        barTitle.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        
        view.addSubview(profileImageView)
        profileImageView.centerX(inView: view)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 48)
        
        view.addSubview(changePhotoButton)
        changePhotoButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: -36, paddingRight: 20)
        
        let stack = UIStackView(arrangedSubviews: [fullnameContainerView, usernameContainerView])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(saveButton)
        saveButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
    }
    
    private func configure() {
        guard let url = URL(string: viewModel.user.profileImageUrl) else { return }
        profileImageView.sd_setImage(with: url)
        
        usernameTextField.text = viewModel.user.username
        fullnameTextField.text = viewModel.user.fullname
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.newProfileImage = image
        
        profileImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
