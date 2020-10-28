//
//  MapViewController.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/15/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import MapKit
import Hero
import AwesomeEnum
import Lottie
import Material

protocol MapSelectionDelegate {
    func didSelectAddress(addressTextField: AddressTextField)
}

class MapViewController: UIViewController, AddressFieldDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    private var mapView = MKMapView()
    var addressTextField = AddressTextField(nil, canEditTextField: true)
    let animationView = AnimationView(name: "searching", bundle: Bundle.main)
    
    let userLocationPin = MKPointAnnotation()
    let locationPin = MKPointAnnotation()
    var didUpdateLocation : Bool = false
    
    var delegate : MapSelectionDelegate?
    
    var searching : Bool = DirectionManager.instance.userLocation == nil {
        didSet {
            if searching {
                animationView.play()
            } else {
                animationView.stop()
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .themeWhite
        
        mapView.delegate = self
        DirectionManager.instance.resetUserLocation()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(action(gestureRecognizer:)))
        gesture.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(gesture)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchedView))
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)
        
        animationView.loopMode = .loop
        animationView.animationSpeed = 2
        animationView.isUserInteractionEnabled = false
        animationView.play()
        view.addSubview(animationView)
        let height = 60
        let width = 60
        animationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.right.equalToSuperview().offset(-36)
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
        
        let searchButton = FlatButton()
        searchButton.backgroundColor = .clear
        searchButton.addTarget(self, action: #selector(pressedSearchButton), for: .touchUpInside)
        self.view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(animationView)
        }
        
        let titleLabel = TitleLabel("Select Location")
        titleLabel.textAlignment = .left
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-64)
        }
        
        addressTextField.delegate = self
        addressTextField.textField.textField.delegate = self
        self.view.addSubview(addressTextField)
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-64)
            make.height.equalTo(75)
        }
        _ = addressTextField.becomeFirstResponder()
        
        self.view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(40)
            make.bottom.left.right.equalToSuperview()
        }
        
        let buttonSize : CGFloat = 60
        let confirmImage = Awesome.Solid.check.asImage(size: buttonSize / 2, color: .themeWhite, backgroundColor: .clear)
        let nextButton = CircleButton(image: confirmImage, color: .theme1, size: buttonSize)
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        self.view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-36)
            make.right.equalToSuperview().offset(-36)
            make.width.height.equalTo(buttonSize)
        }
        
        let backImage = Awesome.Solid.chevronLeft.asImage(size: buttonSize / 2, color: .themeWhite, backgroundColor: .clear)
        let backButton = CircleButton(image: backImage, color: .theme4, size: buttonSize)
        backButton.isHidden = false
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-36)
            make.left.equalToSuperview().offset(36)
            make.width.height.equalTo(buttonSize)
        }
        
        // if location is selected
        // center it and pin it
        if let location = addressTextField.selectedMapItem {
            didSelectAddress(location)
            return
        }
        // else if only user location is known
        // center and pin it
        if let userLocation = DirectionManager.instance.userLocation {
            searching = false
            getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude) { name in
                self.userLocationPin.title = name
                self.locationPin.coordinate = userLocation.coordinate
                self.mapView.addAnnotation(self.userLocationPin)
                self.didUpdateUserLocation(userLocation)
            }
            return
        }
        
        // hawaii , if we know nothing
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        mapView.centerToLocation(initialLocation)
    }
    
    @objc func action(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        getAddressFromLatLon(pdblLatitude: newCoordinates.latitude, withLongitude: newCoordinates.longitude) { name in
            self.locationPin.title = name
            self.locationPin.coordinate = newCoordinates
            self.mapView.addAnnotation(self.locationPin)
            self.didSelectAddress(Location(name: name, latitude: newCoordinates.latitude, longitude: newCoordinates.longitude))
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let latitude = view.annotation?.coordinate.latitude,
            let longitide = view.annotation?.coordinate.longitude else { return }
        addressTextField.selectedMapItem = Location(name: view.annotation?.title ?? "", latitude: latitude, longitude: longitide)
        addressTextField.textField.textField.text = view.annotation?.title ?? ""
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        if annotationView?.annotation?.coordinate.latitude == userLocationPin.coordinate.latitude &&
            annotationView?.annotation?.coordinate.longitude == userLocationPin.coordinate.longitude {
            annotationView?.tintColor = .theme1
        } else {
            annotationView?.tintColor = .theme4
        }
        
        return annotationView
    }
    
    @objc func pressedSearchButton() {
        if let userLocation = DirectionManager.instance.userLocation {
            getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude) { name in
                self.userLocationPin.title = name
                self.userLocationPin.coordinate = userLocation.coordinate
                self.mapView.addAnnotation(self.userLocationPin)
                self.didUpdateUserLocation(userLocation)
                self.mapView.centerToLocation(userLocation)
            }
        } else {
            animationView.stop()
            animationView.play()
            if !searching {
                DirectionManager.instance.resetUserLocation()
            }
        }
    }
    
    func setAddressField(_ field : AddressTextField) {
        self.addressTextField.textField.placeholderLabel.text = field.textField.placeholderLabel.text
        self.addressTextField.textField.textField.text = field.textField.textField.text
        self.addressTextField.selectedMapItem = field.selectedMapItem
    }
    
    @objc func nextButtonPressed() {
        delegate?.didSelectAddress(addressTextField: self.addressTextField)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func backButtonPressed() {
        self.addressTextField.selectedMapItem = nil
        self.addressTextField.textField.textField.text = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc private func touchedView() {
        self.view.endEditing(true)
    }
    
    func didTapTextField(_ textField: UITextField) {}
    
    func didSelectAddress(_ location: Location) {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        mapView.centerToLocation(clLocation)
        locationPin.coordinate = clLocation.coordinate
        locationPin.title = location.name
        mapView.addAnnotation(locationPin)
        mapView.selectAnnotation(locationPin, animated: true)
        addressTextField.selectedMapItem = location
        addressTextField.textField.textField.text = location.name
    }
    
    func didUpdateUserLocation(_ userLocation: CLLocation) {
        mapView.centerToLocation(userLocation)
        userLocationPin.coordinate = userLocation.coordinate
        getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude) {
            name in
            self.userLocationPin.title = name
            self.mapView.addAnnotation(self.userLocationPin)
            self.mapView.selectAnnotation(self.userLocationPin, animated: true)
        }
    }
    
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double, completion: @escaping ((String?) -> Void)) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = pdblLatitude
        let lon: Double = pdblLongitude
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    completion(nil)
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                guard let pm = placemarks else {
                    completion(nil)
                    return
                }
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality!
                    }
                    completion(addressString)
                }
        })
        
    }
    
}

private extension MKMapView {
    
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
