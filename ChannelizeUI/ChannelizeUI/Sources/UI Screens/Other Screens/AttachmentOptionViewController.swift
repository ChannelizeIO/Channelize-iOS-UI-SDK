//
//  AttachmentOptionViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/27/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

enum ActionType {
    case destructive
    case normal
    case cancel
}

class AttachmentOptionModel {
    var icon: String?
    var text: String?
    var identifier: String
    var actionType: ActionType
    
    init(icon: String?, label: String?, identifier: String, actionType: ActionType) {
        self.icon = icon
        self.text = label
        self.identifier = identifier
        self.actionType = actionType
    }
    
}

class AttachmentOptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var options = [AttachmentOptionModel]()
    
    private var cancelButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(CHLocalized(key: "pmCancel"), for: .normal)
        button.setTitleColor(CHUIConstants.appDefaultColor, for: .normal)
        
        return button
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset.top = 0
        self.tableView.contentInset.bottom = 0
        self.tableView.isScrollEnabled = false
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        
        let totalTableViewHeight: CGFloat = CGFloat(self.options.count * 50)
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        self.tableView.setHeightAnchor(constant: totalTableViewHeight)
        
        // Do any additional setup after loading the view.
    }
    
    // MARK:- TableView Delegates and DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        let option = self.options[indexPath.row]
        cell.textLabel?.text = option.text
        cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
        cell.imageView?.image = getImage(option.icon ?? "")
        switch option.actionType {
        case .normal:
            cell.textLabel?.textColor = .black
            cell.imageView?.tintColor = .black
            break
        case .destructive:
            cell.textLabel?.textColor = UIColor.customSystemRed
            cell.imageView?.tintColor = UIColor.customSystemRed
            break
        default:
            cell.textLabel?.textColor = UIColor.customSystemBlue
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
