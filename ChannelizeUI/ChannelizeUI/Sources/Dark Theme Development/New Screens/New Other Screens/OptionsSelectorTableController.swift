import Foundation
import ChannelizeAPI
import UIKit

enum OptionScreenType {
    case videoQuality
    case userOnlineOffline
}

class OptionsSelectorTableController: NewCHTableViewController {
    
    var dataString = [String]()
    var lastSelection: IndexPath?
    var selectorType : OptionScreenType? = .userOnlineOffline
    
    var onVideoQualityOptionChange: (() -> Void)?
    var onStatusChanged: (() -> Void)?
    
    init() {
        super.init(tableStyle: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#38383a") : UIColor(hex: "#c6c6c8")
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        self.tableView.allowsMultipleSelection = false
        
        if self.selectorType == .videoQuality{
            let videoQuality = UserDefaults.standard.object(forKey: "CHVideoCallQuality") as? String ?? VideoCallQuality.Quality960x720.rawValue
            if let index = dataString.firstIndex(of: videoQuality){
                lastSelection = IndexPath(item: index, section: 0)
            }
        } else if self.selectorType == .userOnlineOffline{
            let status = UserDefaults.standard.object(forKey: ChannelizeKeys.isUserOnline.key()) as? Bool ?? false
            if status{
                lastSelection = IndexPath(item: 1, section: 0)
            } else{
                lastSelection = IndexPath(item: 0, section: 0)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataString.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        cell.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tableCellBackGroundColor : CHLightThemeColors.tableCellBackGroundColor
        cell.selectionStyle = .none
        cell.textLabel?.text = self.dataString[indexPath.item]
        cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
        cell.textLabel?.textColor = CHUIConstant.settingsScreenMainLabelColor
        if indexPath.item == lastSelection?.item {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.lastSelection != nil {
            self.tableView.cellForRow(at: self.lastSelection!)?.accessoryType = .none
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        if self.selectorType == .videoQuality{
            self.onVideoQualityOptionChange?()
            UserDefaults.standard.set(self.dataString[indexPath.item], forKey: "CHVideoCallQuality")
        } else if self.selectorType == .userOnlineOffline{
            let value = (indexPath.item as NSNumber).boolValue
            var params = [String:Any]()
            params.updateValue(value, forKey: "isOnline")
            showProgressView(superView: self.navigationController?.view, string: nil)
            ChannelizeAPIService.updateUserSettings(params: params, completion: {(status,errorString) in
                if status {
                    showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
                    UserDefaults.standard.set(value, forKey: ChannelizeKeys.isUserOnline.key())
                    self.onStatusChanged?()
                } else {
                    showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                }
            })
        }
        self.lastSelection = indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


