//
//  UIDetailedCallLogController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHCallButton: UIButton {

    override var isEnabled: Bool {
        didSet{
            if self.isEnabled {
                self.imageView?.tintColor = UIColor.white
            }
            else{
                self.imageView?.tintColor = UIColor.lightGray
            }
        }
    }
}

class UIDetailedCallLogController: UITableViewController {
    
    private var headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(hex: "#f8f8f8")
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var callPartnerNameLabel: UILabel = {
        let label = UILabel()
        label.font = CHUIConstants.conversationTitleFont
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        return label
    }()
    
    private var voiceCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        return button
    }()
    
    private var videoCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        return button
    }()
    
    private var headerView: DetailedCallLogHeaderView = {
        let view = DetailedCallLogHeaderView()
        return view
    }()
    
    var calls = [CHCall]()
    var callPartner: CHCallMember?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.titleView = self.headerView
        self.headerView.onBackButtonTapped = {[weak self](sender) in
            self?.navigationController?.popViewController(animated: true)
        }
        self.headerView.assignHeaderViewData(callPartner: callPartner)
        //self.setUpHeaderView()
        //self.assignHeaderViewData()
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.tableFooterView = UIView()
        //self.headerContainerView.frame.size.height = 75
        //self.tableView.tableHeaderView = self.headerContainerView
        self.tableView.register(UIDetailedCallLogCell.self, forCellReuseIdentifier: "detailedCallLogCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func setUpHeaderView() {
        self.headerContainerView.addSubview(profileImageView)
        self.headerContainerView.addSubview(callPartnerNameLabel)
        self.headerContainerView.addSubview(videoCallButton)
        self.headerContainerView.addSubview(voiceCallButton)
        
        self.profileImageView.setViewAsCircle(circleWidth: 30)
        self.profileImageView.setLeftAnchor(relatedConstraint: self.headerContainerView.leftAnchor, constant: 12.5)
        self.profileImageView.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        
        self.callPartnerNameLabel.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 12.5)
        self.callPartnerNameLabel.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        self.callPartnerNameLabel.setHeightAnchor(constant: 25)
        self.callPartnerNameLabel.setWidthAnchor(constant: 200)
        
        self.videoCallButton.setViewsAsSquare(squareWidth: 40)
        self.videoCallButton.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        self.videoCallButton.setRightAnchor(relatedConstraint: self.headerContainerView.rightAnchor, constant: -10)
        
        self.voiceCallButton.setViewsAsSquare(squareWidth: 40)
        self.voiceCallButton.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        self.voiceCallButton.setRightAnchor(relatedConstraint: self.videoCallButton.leftAnchor, constant: 0)
        
    }
    
    private func assignHeaderViewData() {
        let callPartnerName = callPartner?.user?.displayName?.capitalized
        let profileImageUrl = callPartner?.user?.profileImageUrl
        self.callPartnerNameLabel.text = callPartnerName
        if let imageUrl = URL(string: profileImageUrl ?? "") {
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: callPartnerName ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 60), height: getDeviceWiseAspectedWidth(constant: 60)))
            let image = imageGenerator.generateImage()
            self.profileImageView.image = image
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.calls.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailedCallLogCell", for: indexPath) as! UIDetailedCallLogCell
        let callData = self.calls[indexPath.row]
        let callType = callData.callType ?? .voice
        let callStatusType = callData.myRecipient?.state ?? .Out
        let callDuration = callData.myRecipient?.duration ?? 0.0
        let callTime = callData.createdAt ?? Date()
        
        if callType == .voice {
            cell.imageView?.image = getImage("chVoiceCallIcon")
        } else {
            cell.imageView?.image = getImage("chVideoCallIcon")
        }
        cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
        cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 15.0)
        cell.detailTextLabel?.textColor = CHUIConstants.conversationMessageColor
        switch callStatusType {
        case .In:
            cell.textLabel?.textColor = CHUIConstants.conversationTitleColor
            cell.textLabel?.text = "Incoming"
            cell.imageView?.tintColor = CHUIConstants.appDefaultColor
            break
        case .Missed:
            cell.textLabel?.textColor = UIColor.customSystemRed
            cell.imageView?.tintColor = UIColor.customSystemRed
            cell.textLabel?.text = "Missed"
            break
        case .Out:
            cell.textLabel?.textColor = CHUIConstants.conversationTitleColor
            cell.textLabel?.text = "Outgoing"
            cell.imageView?.tintColor = UIColor.customSystemGreen
            break
        case .Rejected:
            cell.textLabel?.textColor = CHUIConstants.conversationTitleColor
            cell.textLabel?.text = "Rejected"
            cell.imageView?.tintColor = UIColor.customSystemGray
            break
        }
        let callDurationText = (callDuration/1000).asString(style: .abbreviated)
        let callTimingText = callTime.convertDateFormatter()
        let detailedText = "(\(callDurationText)) \(callTimingText)"
        cell.detailTextLabel?.text = detailedText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
