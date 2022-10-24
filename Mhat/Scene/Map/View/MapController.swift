//
//  MapController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 14.06.22.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth
import SDWebImage

class MapController: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()

    let viewModel = MapViewModel()
            
    private let notificationCountLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemRed
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.setDimensions(width: 18, height: 18)
        label.setBorder(borderColor: .white, borderWidth: 2)
        label.clipsToBounds = true
        label.layer.cornerRadius = 18 / 2
        return label
    }()
    
    private lazy var notificationButton: UIButton = {
        let button = buttonMaker(iconName: "bell.fill")
        button.addSubview(notificationCountLabel)
        notificationCountLabel.anchor(top: button.topAnchor, right: button.rightAnchor, paddingTop: 7, paddingRight: 7)
        
        button.addTarget(self, action: #selector(showNotificationController), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = buttonMaker(iconName: "magnifyingglass")
        
        button.addTarget(self, action: #selector(showSearchController), for: .touchUpInside)
        return button
    }()
    
    private lazy var chatButton: UIButton = {
        let button = buttonMaker(iconName: "bubble.left.and.bubble.right.fill")
        
        button.addTarget(self, action: #selector(updateMyLocation), for: .touchUpInside)
        return button
    }()
    
    private lazy var locationButton: UIButton = {
        let button = buttonMaker(iconName: "location.fill")
        
        button.addTarget(self, action: #selector(updateMyLocation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        authenticateUserAndConfigureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        fetchFriends()
        fetchNotificationsCount()
    }
    
    // MARK: - Selectors
    
    @objc func updateMyLocation() {
        viewModel.updateMyLocation { region in
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func showNotificationController() {
        let controller = NotificationController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func showSearchController() {
        let controller = SearchUserController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func logOut() {
        viewModel.logOut()
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    
    func fetchFriends() {
        viewModel.fetchFriends {
            self.configureMapView()
        }
    }
        
    func updateLocation() {
        viewModel.updateLocation()
    }
    
    func fetchNotificationsCount() {
        notificationCountLabel.isHidden = true
        viewModel.fetchNotificationsCount { notificationCount in
            self.notificationCountLabel.isHidden = false
            self.notificationCountLabel.text = "\(notificationCount)"
        }
    }
    
    // MARK: - Helpers
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureMapView()
            fetchFriends()
            fetchNotificationsCount()
        }
    }
    
    func configureMapView() {
        mapView.delegate = self
        locationManager.delegate = self
        mapView.showsCompass = false
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: "identifier")
        view.addSubview(mapView)
        mapView.addConstraintsToFillView(view)
        
        mapView.addAnnotations(viewModel.annotations)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        configureUI()
    }
    
    func configureUI() {
        
        let stack = UIStackView(arrangedSubviews: [chatButton, locationButton])
        stack.axis = .vertical
        stack.spacing = 8
        
        view.addSubview(stack)
        stack.centerY(inView: view)
        stack.anchor(right: view.rightAnchor, paddingRight: 16)
                
        view.addSubview(notificationButton)
        notificationButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
        
        view.addSubview(searchButton)
        searchButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 8, paddingRight: 12)
    }
    
    func refreshMapView() {
        let allAnnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        viewModel.users?.removeAll()
        viewModel.annotations.removeAll()
        fetchFriends()
    }
}

// MARK: - MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = self.viewModel.mapViewCustomAnnotation(mapView: mapView, annotation: annotation)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
            
        self.viewModel.mapViewDidSelect(mapView: mapView, view: view) { user in
            if user.uid == currentUid {
                let controller = CurrentProfileController()
                controller.viewModel.user = user
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
                controller.viewModel.user = user
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
                navigationController?.navigationBar.isHidden = false
            }
        }
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        self.viewModel.locationManager(userLocation: userLocation) { region in
            self.mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - AuthenticationDelegate

extension MapController: AuthenticationDelegate {
    func authenticationComplete() {
        dismiss(animated: true, completion: nil)
        configureMapView()
        fetchFriends()
    }
}

// MARK: - ProfileControllerDelegate

extension MapController: ProfileControllerDelegate {
    func handleRemoveFriend(_ user: User) {
        navigationController?.popToRootViewController(animated: true)
        viewModel.handleRemoveFriend(user) { error in
            if error == nil {
                self.refreshMapView()
            }
        }
    }
    
    func handleLogout() {
        logOut()
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - CustomFunctions

extension MapController {
    func buttonMaker(iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: iconName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "MainColor")
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.setDimensions(width: 48, height: 48)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 48 / 2
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = .init(width: 0, height: 0)
        button.layer.shadowColor = UIColor.lightGray.cgColor
        return button
    }

}
