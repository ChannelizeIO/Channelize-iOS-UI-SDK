//
//  LocationSharingViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/12/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MapKit
import ChannelizeAPI
import InputBarAccessoryView



class LocationSharingViewController: ChannelizeController,UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    var locationManager: CLLocationManager?
    var myLocationCoordinates: CLLocationCoordinate2D?
    var currentLocationCoordinates: CLLocationCoordinate2D?
    var currentLocationName: String?
    var currentLocationAddress: String?
    var myLocationName: String?
    var myLocationaddress: String?
    
    var nearByLocation: [MKMapItem] = []
    var searchLocation: [MKMapItem] = []
    var isLoadingCurrentLocation = true
    var isLoadingNearbyLocation = true
    var isSearchingLocation = false
    var loadingInProgress = false
    var keyboardManager = KeyboardManager()
    var isMapLoadedSuccessfully = false
    var delegate: LocationSharingControllerDelegates?
    let request = MKLocalSearch.Request()
    var mkRequestSearch: MKLocalSearch?
    private var locationSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.tintColor = CHCustomStyles.searchBarTintColor
        searchBar.textField?.tintColor = CHCustomStyles.searchBarTextColor
        searchBar.setTextFieldBackgroundColor(color: CHCustomStyles.searchBarBackgroundColor)
        return searchBar
    }()
    
    private var mapContainerView: UIView = {
        let view = UIView()
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var placesInThisAreaButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        button.setTitle("Places in this Area", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var moveToCurrentLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.setImage(getImage("chCurrentLocatioButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    private var sendLocationButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.setImage(getImage("chMessageSendButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        return button
    }()
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        view.hidesWhenStopped = true
        return view
    }()
    
    private var loadingIndicator2: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        view.hidesWhenStopped = true
        return view
    }()
    
    private var mapView: MKMapView?
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.tag = 1001
        return tableView
    }()
    
    private var locationSearchTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.tag = 1002
        return tableView
    }()
    
    var mapViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: "#f2f2f7")
        self.edgesForExtendedLayout = []
        
        keyboardManager.bind(to: self.locationSearchTableView)
        keyboardManager.on(event: .willShow, do: {(notification) in
            let keyboardHeight = notification.endFrame.height
            self.locationSearchTableView.contentInset.bottom = keyboardHeight
        }).on(event: .willHide, do: {(notification) in
            self.locationSearchTableView.contentInset.bottom = 0
        })
        
        
        self.locationSearchBar.delegate = self
        self.navigationItem.titleView = self.locationSearchBar
        //self.navigationItem.hidesBackButton = true
        
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = 100
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareMapView()
        self.setUpViews()
        self.setUpTableView()
        self.setUpViewsFrames()
    }
    
    private func prepareMapView() {
        mapView = MKMapView()
        mapView?.mapType = MKMapType.standard
        mapView?.isZoomEnabled = true
        mapView?.isScrollEnabled = true
        mapView?.showsCompass = true
        mapView?.showsBuildings = true
        mapView?.showsTraffic = true
        mapView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            self.locationManager?.stopUpdatingLocation()
            self.mapView?.showsUserLocation = false
            self.locationManager?.delegate = nil
            self.locationManager = nil
            self.mapView?.delegate = nil
            self.applyMapViewMemoryFix()
            self.locationSearchBar.delegate = nil
            self.tableView.delegate = nil
            self.tableView.dataSource = nil
            self.locationSearchTableView.delegate = nil
            self.locationSearchTableView.dataSource = nil
        }
    }
    
    func applyMapViewMemoryFix() {
        switch (self.mapView?.mapType ?? .hybrid) {
        case MKMapType.hybrid:
            self.mapView?.mapType = MKMapType.standard
        case MKMapType.standard:
            self.mapView?.mapType = MKMapType.hybrid
        default:
            break
        }
        self.mapView?.showsUserLocation = false
        self.mapView?.delegate = nil
        self.mapView?.removeFromSuperview()
    }
    
    deinit {
        self.locationManager?.stopUpdatingLocation()
        self.mapView?.showsUserLocation = false
        self.locationManager?.delegate = nil
        self.locationManager = nil
        self.mapView?.delegate = nil
    }
    
    private func setUpViews() {
        
        self.mapContainerView.addSubview(self.mapView!)
        self.mapContainerView.addSubview(placesInThisAreaButton)
        self.mapContainerView.addSubview(moveToCurrentLocationButton)
        
        self.placesInThisAreaButton.setCenterXAnchor(
            relatedConstraint: self.mapContainerView.centerXAnchor, constant: 0)
        self.placesInThisAreaButton.setTopAnchor(relatedConstraint: self.mapContainerView.topAnchor, constant: 25)
        self.placesInThisAreaButton.setHeightAnchor(constant: 40)
        self.placesInThisAreaButton.setWidthAnchor(constant: 200)
        
        self.moveToCurrentLocationButton.setViewAsCircle(circleWidth: 45)
        self.moveToCurrentLocationButton.setBottomAnchor(
            relatedConstraint: self.mapContainerView.bottomAnchor, constant: -15)
        self.moveToCurrentLocationButton.setRightAnchor(
            relatedConstraint: self.mapContainerView.rightAnchor, constant: -15)
        
        self.mapView?.pinEdgeToSuperView(superView: self.mapContainerView)
        
        self.placesInThisAreaButton.addTarget(self, action: #selector(didPressPlacesInThisAreaButton(sender:)), for: .touchUpInside)
        self.moveToCurrentLocationButton.addTarget(self, action: #selector(moveToCurrentLocations(sender:)), for: .touchUpInside)
        
        
        self.view.addSubview(locationSearchTableView)
        self.view.addSubview(tableView)
        self.locationSearchTableView.isHidden = true
        
        self.sendLocationButton.addTarget(self, action: #selector(didPressSendCurrentLocationButton(sender:)), for: .touchUpInside)
        //self.view.addSubview(mapContainerView)
        //self.mapContainerView.addSubview(mapView)
    }
    
    private func setUpViewsFrames() {
        /*
        self.mapContainerView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.mapContainerView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.mapContainerView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.mapViewHeightConstraint = NSLayoutConstraint(item: self.mapContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 350)
        self.mapViewHeightConstraint.isActive = true
        self.view.addConstraint(self.mapViewHeightConstraint)
        */
        self.locationSearchTableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.locationSearchTableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.locationSearchTableView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.locationSearchTableView.setBottomAnchor(relatedConstraint: self.view.bottomAnchor, constant: 0)
        
        
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.tableView.setBottomAnchor(relatedConstraint: self.view.bottomAnchor, constant: 0)
    }
    
    private func setUpTableView() {
        
        self.locationSearchTableView.dataSource = self
        self.locationSearchTableView.delegate = self
        self.locationSearchTableView.tableFooterView = UIView()
        self.locationSearchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "nearByLocationsCell")
        self.locationSearchTableView.contentInset.top = 10
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.mapView?.delegate = self
        self.mapContainerView.frame.size.height = 350
        self.tableView.tableHeaderView = self.mapContainerView
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "currentLocationCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "nearByLocationsCell")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1001 {
            return 2
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1001 {
            if section == 0 {
                return 1
            } else {
                if self.isLoadingNearbyLocation == true {
                    return 1
                } else {
                    return self.nearByLocation.count
                }
            }
        } else {
            return self.searchLocation.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1001 {
            if indexPath.section == 0 {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "currentLocationCell")
                cell.textLabel?.font = UIFont(fontStyle: .robotoMedium, size: 18.0)
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
                cell.detailTextLabel?.textColor = .darkGray
                cell.backgroundColor = UIColor.white
                self.sendLocationButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
                if self.isLoadingCurrentLocation == true {
                    cell.textLabel?.text = "Loading Current Location"
                    cell.detailTextLabel?.text = nil
                    cell.accessoryView = self.loadingIndicator
                } else {
                    cell.textLabel?.text = self.currentLocationName
                    cell.detailTextLabel?.text = self.currentLocationAddress
                    cell.accessoryView = self.sendLocationButton
                }
                cell.selectionStyle = .none
                return cell
            } else {
                if self.isLoadingNearbyLocation == true {
                    let cell = UITableViewCell()
                    cell.textLabel?.font = UIFont(fontStyle: .robotoMedium, size: 18.0)
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.text = "Loading Nearby Location"
                    cell.accessoryView = self.loadingIndicator2
                    cell.selectionStyle = .none
                    return cell
                } else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "nearByLocationsCell")
                    cell.textLabel?.font = UIFont(fontStyle: .robotoSlabMedium, size: 18.0)
                    cell.textLabel?.textColor = .black
                    cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
                    cell.detailTextLabel?.textColor = .darkGray
                    let locationName = nearByLocation[indexPath.row].placemark.name
                    cell.textLabel?.text = locationName
                    let locationAddress = parseAddress(place: nearByLocation[indexPath.row].placemark)
                    cell.detailTextLabel?.text = locationAddress
                    cell.backgroundColor = UIColor.white
                    cell.selectionStyle = .none
                    return cell
                }
            }
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "nearByLocationsCell")
            cell.textLabel?.font = UIFont(fontStyle: .robotoSlabMedium, size: 18.0)
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
            cell.detailTextLabel?.textColor = UIColor.darkGray
            let locationName = searchLocation[indexPath.row].placemark.name
            cell.textLabel?.text = locationName
            let locationAddress = parseAddress(place: searchLocation[indexPath.row].placemark)
            cell.detailTextLabel?.text = locationAddress
            cell.backgroundColor = UIColor.white
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.tag == 1001 {
            if section == 0 {
                return "Send Current Location"
            } else {
                return "Nearby Places"
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1001 {
            if indexPath.section == 1 {
                if self.loadingInProgress == false {
                    let placeMark = self.nearByLocation[indexPath.row].placemark
                    let locationName = placeMark.name
                    let locationAddress = parseAddress(place: placeMark)
                    let locationCoordinates = placeMark.location?.coordinate
                    self.delegate?.didSelectLocation(coordinates: locationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: locationName ?? "", address: locationAddress)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            if self.loadingInProgress == false {
                let placeMark = self.searchLocation[indexPath.row].placemark
                let locationName = placeMark.name
                let locationAddress = parseAddress(place: placeMark)
                let locationCoordinates = placeMark.location?.coordinate
                self.delegate?.didSelectLocation(coordinates: locationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: locationName ?? "", address: locationAddress)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y)
        let height = max(min(y,300),0)
        //let height = min(max(y, 0), 300)
        UIView.animate(withDuration: 0.01, animations: {
            self.mapViewHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        })
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            self.isMapLoadedSuccessfully = true
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            self.myLocationCoordinates = center
            currentLocationCoordinates = self.myLocationCoordinates
            var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
            region = self.mapView!.regionThatFits(region)
            self.mapView?.setRegion(region, animated: false)
            self.mapView?.showsUserLocation = true
            self.getCurrentLocation(location.coordinate)
            self.getNearbyLocations()
        }
    }
    
    func getCurrentLocation(_ location:CLLocationCoordinate2D){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { [weak self]
            (placemarks, error) -> Void in
            if var placemark: CLPlacemark = placemarks?[0]{
                placemark = (placemarks?[0])!
                self?.currentLocationName = placemark.name
                self?.currentLocationAddress = self?.getAdderess(placemark)
                self?.myLocationName = self?.currentLocationName
                self?.myLocationaddress = self?.currentLocationAddress
                self?.isLoadingCurrentLocation = false
                self?.tableView.reloadData()
            }
        })
    }
    
    func getAdderess(_ placemark:CLPlacemark)-> String{
        var addressString : String = ""
        if let subLocality =  placemark.subLocality{
            addressString = addressString + subLocality + ", "
        }
        if let throughFare = placemark.thoroughfare{
            addressString = addressString + throughFare + ", "
        }
        if let locality = placemark.locality{
            addressString = addressString + locality + ", "
        }
        if let country = placemark.country{
            addressString = addressString + country + ", "
        }
        if let postalCode = placemark.postalCode{
            addressString = addressString + postalCode + " "
        }
        return addressString
    }
    
    func parseAddress(place: MKPlacemark?) -> String{
        if let place = place {
            let firstSpace = (place.subThoroughfare != nil && place.thoroughfare != nil) ? " " : ""
            let comma = (place.subThoroughfare != nil || place.thoroughfare != nil) && (place.subAdministrativeArea != nil || place.administrativeArea != nil) ? ", " : ""
            let secondSpace = (place.subAdministrativeArea != nil && place.administrativeArea != nil) ? " " : ""
            let addressLine = String(
                format:"%@%@%@%@%@%@%@",
                place.subThoroughfare ?? "",
                firstSpace,
                place.thoroughfare ?? "",
                comma,
                place.locality ?? "",
                secondSpace,
                place.administrativeArea ?? ""
            )
            return addressLine
        }
        return ""
    }
    
    private func getNearbyLocations(query:String = CHLocalized(key: "pmNearby")){
        
        request.naturalLanguageQuery = query
        request.region = mapView!.region
        if self.mkRequestSearch != nil {
            self.mkRequestSearch?.cancel()
            self.mkRequestSearch = nil
        }
        self.mkRequestSearch = MKLocalSearch(request: request)
        //let search = MKLocalSearch(request: request)
        //search.can
        self.mkRequestSearch?.start {[weak self] (oldResponse,error) in
            guard error == nil else{
                self?.getNearbyLocations(query: query)
                return
            }
            guard let response = oldResponse else {
                return
            }
            if self?.isSearchingLocation == true {
                self?.searchLocation.removeAll()
                self?.searchLocation = response.mapItems
                self?.locationSearchTableView.reloadData()
            } else {
                self?.nearByLocation.removeAll()
                self?.nearByLocation = response.mapItems
                self?.tableView.reloadData()
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.tableView.isHidden = true
        self.locationSearchTableView.isHidden = false
        self.isSearchingLocation = true
        self.locationSearchBar.setShowsCancelButton(true, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.tableView.isHidden = false
        self.isSearchingLocation = false
        self.locationSearchTableView.isHidden = true
        self.locationSearchBar.setShowsCancelButton(false, animated: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else{
            return
        }
        self.getNearbyLocations(query: searchText)
    }

    // Mark :- MapView Delegates
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.isMapLoadedSuccessfully == true {
            self.placesInThisAreaButton.isHidden = false
        }
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("User Location Coordinates \(userLocation.coordinate)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc private func didPressPlacesInThisAreaButton(sender: UIButton) {
        self.getNearbyLocations()
    }
    
    @objc func moveToCurrentLocations(sender:UIButton){
        self.placesInThisAreaButton.isHidden = true
        currentLocationCoordinates = myLocationCoordinates
        if let region = currentLocationCoordinates{
            currentLocationName = myLocationName
            currentLocationAddress = myLocationaddress
            let region = MKCoordinateRegion(center: region, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView?.setRegion(region, animated: true)
            //getNearbyLocations()
            mapView?.removeAnnotations(mapView?.annotations ?? [])
        }
    }
    
    @objc func didPressSendCurrentLocationButton(sender: UIButton) {
        self.delegate?.didSelectLocation(coordinates: currentLocationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: currentLocationName ?? "", address: currentLocationAddress ?? "")
        self.navigationController?.popViewController(animated: true)
    }

}

