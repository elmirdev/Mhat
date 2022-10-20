//
//  ChatController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 20.06.22.
//

import UIKit

private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController {
    // MARK: - Properties
    
    weak var delegate: ProfileControllerDelegate?
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "arrow.backward", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .customBlue
        
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDimensions(width: 40, height: 40)
        imageView.setBorder(borderColor: .customBlue, borderWidth: 1)
        imageView.layer.cornerRadius = 40 / 2
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        imageView.addGestureRecognizer(gesture)
        
        return imageView
    }()
        
    let viewModel = ChatViewModel()
    
    // MARK: - Lifecyle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureBarButton()
        fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Selectors
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showProfile() {
        let controller = ProfileController()
        controller.viewModel.user = viewModel.user
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - API
    
    func fetchMessages() {
        showLoader(true)
        
        viewModel.fetchMessages {
            self.showLoader(false)
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.viewModel.messages.count - 1], at: .top, animated: true)
        }
        showLoader(false)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        configureNavigationBar(withTitle: viewModel.user.username, backgroundColor: .white, prefersLargeTitles: false)
        
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func configureBarButton() {
        guard let url = URL(string: viewModel.user.profileImageUrl) else { return }
        profileImageView.sd_setImage(with: url)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileImageView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

}

// MARK: - UICollectionViewDataSource

extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.message = viewModel.messages[indexPath.row]
        cell.message?.user = viewModel.user
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChatController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimatedSizeCell = MessageCell(frame: frame)
        estimatedSizeCell.message = viewModel.messages[indexPath.row]
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
}

// MARK: - CustomInputAccessoryViewDelegate

extension ChatController: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
       
        inputView.clearMessageText()
        viewModel.uploadMesssage(message: message)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ChatController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
