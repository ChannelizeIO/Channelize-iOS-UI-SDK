//
//  LocationSearchTableController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSharingControllerDelegates: class {
    func didSelectLocation(coordinates: CLLocationCoordinate2D, name: String, address: String)
}

class LocationSearchTableController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

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
    
    var delegate: LocationSharingControllerDelegates?
    //private var mapView: MKMapView?
    private var locationSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.tintColor = CHCustomStyles.searchBarTintColor
        searchBar.textField?.tintColor = CHCustomStyles.searchBarTextColor
        searchBar.setTextFieldBackgroundColor(color: CHCustomStyles.searchBarBackgroundColor)
        return searchBar
    }()
    
    private var mapView: MKMapView?
    
    private var mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
    
    private var sendLocationButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.setImage(getImage("chMessageSendButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        return button
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
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        #endif
        self.view.backgroundColor = UIColor(hex: "#f2f2f7")
        self.locationSearchBar.delegate = self
        self.navigationItem.titleView = self.locationSearchBar
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = 100
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "currentLocationCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "nearByLocationsCell")
        
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
            return self.searchLocation.count
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
            cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 15.0)
            cell.detailTextLabel?.textColor = UIColor.darkGray
            let locationName = searchLocation[indexPath.row].placemark.name
            cell.textLabel?.text = locationName
            let locationAddress = parseAddress(place: searchLocation[indexPath.row].placemark)
            cell.detailTextLabel?.text = locationAddress
            cell.backgroundColor = UIColor.white
            cell.selectionStyle = .none
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "currentLocationCell")
                cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 15.0)
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
                    cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.text = "Loading Nearby Location"
                    cell.accessoryView = self.loadingIndicator2
                    cell.selectionStyle = .none
                    return cell
                } else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "nearByLocationsCell")
                    cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
                    cell.textLabel?.textColor = .black
                    cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 15.0)
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
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isSearchingLocation {
            return nil
        } else {
            if section == 0 {
                return "Send Current Location"
            } else {
                return "Nearby Places"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isSearchingLocation {
            let placeMark = self.searchLocation[indexPath.row].placemark
            let locationName = placeMark.name
            let locationAddress = parseAddress(place: placeMark)
            let locationCoordinates = placeMark.location?.coordinate
            self.delegate?.didSelectLocation(coordinates: locationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: locationName ?? "", address: locationAddress)
            self.navigationController?.popViewController(animated: true)
        } else {
            if self.loadingInProgress == false {
                let placeMark = self.nearByLocation[indexPath.row].placemark
                let locationName = placeMark.name
                let locationAddress = parseAddress(place: placeMark)
                let locationCoordinates = placeMark.location?.coordinate
                self.delegate?.didSelectLocation(coordinates: locationCoordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: locationName ?? "", address: locationAddress)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK:- Searchbar Delegates
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.isSearchingLocation = true
        self.mapContainerView.frame.size.height = .leastNormalMagnitude
        self.locationSearchBar.setShowsCancelButton(true, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.tableView.reloadData()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
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
        self.getNearbyLocations(query: searchText)
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
    

    // MARK: - MapView Delegates
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
