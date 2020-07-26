//
//  LocationSearchTableController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class CHLocationSharingViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

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
    var isMapLoadedSuccessfully = false
    let request = MKLocalSearch.Request()
    var mkRequestSearch: MKLocalSearch?
    
    private var locationResults = [[String: Any]]()
    var locationSearchTask: DispatchWorkItem?
    
    var delegate: LocationSharingControllerDelegates?
    //private var mapView: MKMapView?
    private var locationSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Location"
        searchBar.keyboardAppearance = CHAppConstant.themeStyle == .dark ? .dark : .light
        searchBar.textField?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        searchBar.textField?.borderStyle = .roundedRect
        searchBar.textField?.layer.borderWidth = 0.0
        searchBar.textField?.font = UIFont(fontStyle: .regular, size: 17.0)
        searchBar.textField?.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: UIBarMetrics.default)
        searchBar.setTextFieldBackgroundColor(color: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#2c2c2c") : UIColor(hex: "#e6e6e6"))
        searchBar.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.buttonsTintColor : CHLightThemeColors.buttonsTintColor
        searchBar.addBottomBorder(with: .white, andWidth: 0.5)
        return searchBar
    }()
    
    private var mapView: MKMapView?
    
    private var mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let view = CHAppConstant.themeStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        view.hidesWhenStopped = true
        return view
    }()
    
    private var loadingIndicator2: UIActivityIndicatorView = {
        let view = CHAppConstant.themeStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        view.hidesWhenStopped = true
        return view
    }()
    
    private var sendLocationButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.setImage(getImage("chMessageSendButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        return button
    }()
    
    private var placesInThisAreaButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        button.setTitle("Places in this Area", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(fontStyle: .regular, size: 18.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var moveToCurrentLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.setImage(getImage("chCurrentLocatioButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: "#f2f2f7")
        self.locationSearchBar.delegate = self
        self.navigationItem.titleView = self.locationSearchBar
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.distanceFilter = 100
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "currentLocationCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "nearByLocationsCell")
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#000000") : UIColor(hex: "#f2f2f8")
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.tableView.contentInset.top = 10
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareMapView()
        //self.setUpViews()
        //self.setUpTableView()
        //self.setUpViewsFrames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            self.navigationItem.titleView = nil
        }
    }
    
    deinit {
        self.mapView?.annotations.forEach({
            self.mapView?.removeAnnotation($0)
        })
        self.mapView?.delegate = nil
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.delegate = nil
        self.locationManager = nil
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
        self.mapView?.delegate = self
        
        self.mapContainerView.addSubview(mapView!)
        self.mapContainerView.addSubview(placesInThisAreaButton)
        self.mapContainerView.addSubview(moveToCurrentLocationButton)
        
        self.mapView?.pinEdgeToSuperView(superView: self.mapContainerView)
        self.mapContainerView.frame.size.height = 350
        self.tableView.tableHeaderView = self.mapContainerView
        
        self.placesInThisAreaButton.setCenterXAnchor(
            relatedConstraint: self.mapContainerView.centerXAnchor, constant: 0)
        self.placesInThisAreaButton.setTopAnchor(relatedConstraint: self.mapContainerView.topAnchor, constant: 25)
        self.placesInThisAreaButton.setHeightAnchor(constant: 40)
        self.placesInThisAreaButton.setWidthAnchor(constant: 200)
        self.placesInThisAreaButton.isHidden = true
        
        self.moveToCurrentLocationButton.setViewAsCircle(circleWidth: 45)
        self.moveToCurrentLocationButton.setBottomAnchor(
            relatedConstraint: self.mapContainerView.bottomAnchor, constant: -15)
        self.moveToCurrentLocationButton.setRightAnchor(
            relatedConstraint: self.mapContainerView.rightAnchor, constant: -15)
        
        self.placesInThisAreaButton.addTarget(self, action: #selector(didPressPlacesInThisAreaButton(sender:)), for: .touchUpInside)
        self.moveToCurrentLocationButton.addTarget(self, action: #selector(moveToCurrentLocations(sender:)), for: .touchUpInside)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.isSearchingLocation == true {
            return 1
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isSearchingLocation {
            return self.locationResults.count
        } else {
            if section == 0 {
                return 1
            } else {
                if self.isLoadingNearbyLocation == true {
                    return 1
                } else {
                    return self.nearByLocation.count
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearchingLocation {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "nearByLocationsCell")
            cell.textLabel?.font = UIFont(fontStyle: .regular, size: 17.0)
            cell.textLabel?.textColor = CHUIConstant.recentConversationTitleColor
            cell.detailTextLabel?.font = UIFont(fontStyle: .regular, size: 15.0)
            cell.detailTextLabel?.textColor = CHUIConstant.recentConversationMessageColor
            let locationName = self.locationResults[indexPath.row]["name"] as? String
            let locationAddress = self.locationResults[indexPath.row]["address"] as? String
            cell.textLabel?.text = locationName
            cell.detailTextLabel?.text = locationAddress
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
            cell.selectionStyle = .none
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "currentLocationCell")
                cell.textLabel?.font = UIFont(fontStyle: .regular, size: 17.0)
                cell.textLabel?.textColor = CHUIConstant.recentConversationTitleColor
                cell.detailTextLabel?.font = UIFont(fontStyle: .regular, size: 15.0)
                cell.detailTextLabel?.textColor = CHUIConstant.recentConversationMessageColor
                cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
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
                    cell.textLabel?.font = UIFont(fontStyle: .regular, size: 17.0)
                    cell.textLabel?.textColor = CHUIConstant.recentConversationTitleColor
                    cell.textLabel?.text = "Loading Nearby Location"
                    cell.accessoryView = self.loadingIndicator2
                    cell.selectionStyle = .none
                    cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
                    return cell
                } else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "nearByLocationsCell")
                    cell.textLabel?.font = UIFont(fontStyle: .regular, size: 17.0)
                    cell.textLabel?.textColor = CHUIConstant.recentConversationTitleColor
                    cell.detailTextLabel?.font = UIFont(fontStyle: .regular, size: 15.0)
                    cell.detailTextLabel?.textColor = CHUIConstant.recentConversationMessageColor
                    let locationName = nearByLocation[indexPath.row].placemark.name
                    cell.textLabel?.text = locationName
                    let locationAddress = parseAddress(place: nearByLocation[indexPath.row].placemark)
                    cell.detailTextLabel?.text = locationAddress
                    cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.isSearchingLocation == false else {
            return 0
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.isSearchingLocation == false else {
            return nil
        }
        if section == 0 {
            let backGroundView = UIView()
            backGroundView.backgroundColor = .clear
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Send Current Location"
            label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
            label.font = UIFont(fontStyle: .regular, size: 16)
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        } else {
            let backGroundView = UIView()
            backGroundView.backgroundColor = .clear
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Nearby Places"
            label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
            label.font = UIFont(fontStyle: .regular, size: 16)
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isSearchingLocation {
            let locationDetail = self.locationResults[indexPath.row]
            self.createGetPlaceDetailsApi(placeId: locationDetail["placeId"] as? String ?? "", completion: {(coordinates) in
                self.delegate?.didSelectLocation(coordinates: coordinates, name: locationDetail["name"] as? String ?? "", address: locationDetail["address"] as? String ?? "")
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            if indexPath.section == 0 {
                if self.isLoadingCurrentLocation == false {
                    self.delegate?.didSelectLocation(coordinates: self.currentLocationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: self.currentLocationName ?? "", address: self.currentLocationAddress ?? "")
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                if self.isLoadingNearbyLocation == false {
                    let placeMark = self.nearByLocation[indexPath.row].placemark
                    let locationName = placeMark.name
                    let locationAddress = parseAddress(place: placeMark)
                    let locationCoordinates = placeMark.location?.coordinate
                    self.delegate?.didSelectLocation(coordinates: locationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: locationName ?? "", address: locationAddress)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK:- Searchbar Delegates
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.isSearchingLocation = true
        self.placesInThisAreaButton.isHidden = true
        self.moveToCurrentLocationButton.isHidden = true
        self.mapContainerView.frame.size.height = .leastNormalMagnitude
        self.locationSearchBar.setShowsCancelButton(true, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.tableView.reloadData()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.placesInThisAreaButton.isHidden = false
        self.moveToCurrentLocationButton.isHidden = false
        self.mapContainerView.frame.size.height = 350
        self.isSearchingLocation = false
        self.locationSearchBar.setShowsCancelButton(false, animated: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else{
            return
        }
        self.locationSearchTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.cancelSearchLocationAPIRequest()
            self?.locationResults.removeAll()
            self?.tableView.reloadData()
            self?.createSearchLocationAPIRequest(query: searchText)
            //self?.perfromGroupSearch(searchQuery: searchText)
        }
        self.locationSearchTask = task
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.50, execute: task)
    }
    
    // MARK: - Location Manager Delegates
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
                self?.tableView.reloadData()
                //self?.locationSearchTableView.reloadData()
            } else {
                self?.isLoadingNearbyLocation = false
                self?.nearByLocation.removeAll()
                self?.nearByLocation = response.mapItems
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - API Functions
    private func createSearchLocationAPIRequest(query: String) {
        
        let url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        var params = [String:Any]()
        params.updateValue(query, forKey: "input")
        params.updateValue(ChUI.instance.getMapKey(), forKey: "key")

        self.cancelSearchLocationAPIRequest()
        self.locationResults.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.init(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal), headers: nil).validate().responseJSON(completionHandler: {[weak self](res ) in
            switch res.result{
            case .success(let value):
                if let returedResponse = value as? NSDictionary {
                    if let resultsArray = returedResponse["predictions"] as? NSArray {
                        self?.processLocationData(data: resultsArray)
                        self?.tableView.reloadData()
                    }
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
    
    private func processLocationData(data: NSArray) {
        data.forEach({
            var params = [String: Any]()
            if let structuredFormatting = ($0 as? NSDictionary)?.value(forKey: "structured_formatting") as? NSDictionary {
                let locationName = structuredFormatting.value(forKey: "main_text") as? String ?? ""
                let locationAddress = structuredFormatting.value(forKey: "secondary_text") as? String ?? ""
                params.updateValue(locationName, forKey: "name")
                params.updateValue(locationAddress, forKey: "address")
            }
            let locationId = ($0 as? NSDictionary)?.value(forKey: "place_id") as? String ?? ""
            params.updateValue(locationId, forKey: "placeId")
            self.locationResults.append(params)
        })
    }
    
    private func cancelSearchLocationAPIRequest() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach {
                if ($0.originalRequest?.url?.absoluteURL.path == "/maps.googleapis.com/maps/api/place/autocomplete/json")
                {
                    $0.cancel()
                }
            }
        }
    }
    
    private func createGetPlaceDetailsApi(placeId: String, completion: @escaping (CLLocationCoordinate2D) -> ()) {
        let url = "https://maps.googleapis.com/maps/api/place/details/json"
        var params = [String: Any]()
        params.updateValue(ChUI.instance.getMapKey(), forKey: "key")
        params.updateValue(placeId, forKey: "placeid")
        
        showProgressView(superView: self.navigationController?.view, string: nil)
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.init(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal), headers: nil).validate().responseJSON(completionHandler: {(res ) in
            disMissProgressView()
            switch res.result{
            case .success(let value):
                if let returedResponse = value as? NSDictionary {
                    if let resultDic = returedResponse["result"] as? NSDictionary {
                        if let geometryDic = resultDic.value(forKey: "geometry") as? NSDictionary{
                            if let locationDic = geometryDic.value(forKey: "location") as? NSDictionary {
                                let latitude = locationDic.value(forKey: "lat") as? Double ?? 0.0
                                let longitude = locationDic.value(forKey: "lng") as? Double ?? 0.0
                                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                completion(coordinate)
                            }
                        }
                    }
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
        
    }
    

    // MARK: - MapView Delegates
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.isMapLoadedSuccessfully == true {
            let region = CLCircularRegion(center: mapView.centerCoordinate, radius: 500, identifier: "centerRegion")
            if region.contains(self.currentLocationCoordinates ?? CLLocationCoordinate2D()) {
                self.placesInThisAreaButton.isHidden = true
            } else {
                self.placesInThisAreaButton.isHidden = false
            }
        }
    }
    
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
            getNearbyLocations()
            mapView?.removeAnnotations(mapView?.annotations ?? [])
        }
    }
    
    @objc func didPressSendCurrentLocationButton(sender: UIButton) {
        self.delegate?.didSelectLocation(coordinates: currentLocationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: currentLocationName ?? "", address: currentLocationAddress ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



