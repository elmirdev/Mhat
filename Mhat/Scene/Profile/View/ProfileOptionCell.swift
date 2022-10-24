//
//  ProfileOptionCell.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 24.10.22.
//

import UIKit

class ProfileOptionCell: UITableViewCell {
    
    // MARK: - Properties
    
    var option: ProfileMenuOptions? {
        didSet { configure() }
    }
    
    private lazy var iconView: UIView = {
        let view = UIView()
        view.addSubview(iconImage)
        iconImage.center(inView: view)
        view.backgroundColor = .systemGray6
        view.setDimensions(width: 36, height: 36)
        view.layer.cornerRadius = 36 / 3
        return view
    }()
    
    private let iconImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 24, height: 24)
        iv.tintColor = .customBlue
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray4
        iv.image = UIImage(systemName: "chevron.right")
        iv.setDimensions(width: 20, height: 20)
        return iv
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(iconView)
        iconView.centerY(inView: self)
        iconView.anchor(left: leftAnchor, paddingLeft: 24)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: self)
        titleLabel.anchor(left: iconView.rightAnchor, paddingLeft: 16)
        
        addSubview(chevronIcon)
        chevronIcon.centerY(inView: self)
        chevronIcon.anchor(right: rightAnchor, paddingRight: 24)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        iconImage.image = UIImage(systemName: option!.iconName)
        iconImage.tintColor = option?.iconColor
        titleLabel.textColor = option?.textColor
        titleLabel.text = option?.titleText
    }
}

enum ProfileMenuOptions: Int, CaseIterable {
    case editProfile
    case friends
    case settings
    case logOut
    
    var iconName: String {
        switch self {
        case .editProfile: return "person.fill.checkmark"
        case .settings: return "gearshape.fill"
        case .friends: return "person.2.fill"
        case .logOut: return "arrow.right"
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .editProfile: return .customBlue
        case .settings: return .customBlue
        case .friends: return .customBlue
        case .logOut: return .systemRed
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .editProfile: return .black
        case .settings: return .black
        case .friends: return .black
        case .logOut: return .systemRed
        }
    }
    
    var titleText: String {
        switch self {
        case .editProfile: return "Edit Profile"
        case .settings: return "Settings"
        case .friends: return "Friends"
        case .logOut: return "Logout"
        }
    }
}
