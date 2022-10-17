//
//  MapViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 16.10.22.
//

import MapKit
import CoreLocation
import Firebase

class MapViewModel {
        
    // MARK: - Properties
    
    private var locationManager = CLLocationManager()
    
    private var userLocation = CLLocationCoordinate2D()

    private var userAnnotation = MKPointAnnotation()
    
    var annotations = [MKPointAnnotation]()
        
    var users: [User]? {
        didSet { fetchLocations() }
    }
    
    private var isUserLocate = false
    
    var region = MKCoordinateRegion()

    // MARK: - Selectors
    
    func updateMyLocation(completion: @escaping((MKCoordinateRegion)->())) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        completion(region)
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error..")
        }
    }

    
    // MARK: - API
    
    func fetchFriends(completion: @escaping(()->())) {
        Service.shared.fetchFriends { users in
            self.users = users
            self.fetchLocations()
            completion()
        }
    }
    
    func fetchLocations() {
        users?.forEach({ user in
            guard let location = user.location else { return }
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.subtitle = user.uid
            let i = annotations.firstIndex(where: { $0.subtitle == user.uid })
            if i == nil {
//                let allAnnotations = mapView.annotations
//                mapView.removeAnnotations(allAnnotations)
                self.annotations.append(annotation)
                
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.annotations[i!].coordinate = location
                }
            }
        })
    }
    
    func updateLocation() {
        guard Auth.auth().currentUser?.uid != nil else { return }
        Service.shared.updateLocation(coordinate: userLocation) { error in
            if let error = error {
                print("DEBUG: Error qaqo \(error.localizedDescription)")
            }
        }
    }
    
    func fetchNotificationsCount(completion: @escaping((Int)->())) {
        NotificationService.shared.fetchNotificationsCount { notificationCount in
            if notificationCount != 0 {
                completion(notificationCount)
            }
        }
    }
 
    // MARK: - CLLocationManagerDelegate

    func locationManager(userLocation: CLLocationCoordinate2D, completion: @escaping((MKCoordinateRegion)->())) {
        if !isUserLocate {
            self.userLocation = userLocation
            self.userAnnotation.coordinate = userLocation
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            completion(region)
            isUserLocate = true
        }
        self.userLocation = userLocation
        updateLocation()
    }
    
    func mapViewCustomAnnotation(mapView: MKMapView, annotation: MKAnnotation) -> CustomAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "identifier", for: annotation) as! CustomAnnotationView

        guard let index = users?.firstIndex(where: { $0.uid == annotation.subtitle }) else { return nil }
                
        annotationView.user = users?[index]
        
        return annotationView
    }
    
    func mapViewDidSelect(mapView: MKMapView, view: MKAnnotationView, completion: (User)->()) {
        guard let index = users?.firstIndex(where: { $0.uid == view.annotation?.subtitle }) else { return }
        guard let user = users?[index] else { return }
        
        completion(user)
    }
    
    // MARK: - ProfileControllerDelegate

    func handleRemoveFriend(_ user: User, completion: ((Error?) -> Void)?) {
            let uid = user.uid
            Service.shared.removeUserFromFriends(uid: uid, completion: completion)
        }
}

