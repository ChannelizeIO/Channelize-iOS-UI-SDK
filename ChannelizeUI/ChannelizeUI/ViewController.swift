//
//  ViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/17/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

class LoginTableController: UITableViewController {
    
    var loginAccounts = ["leo@ch.com","ter@ch.com","jordi@ch.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login Accounts"
        UIFont.loadMyFonts
        if Channelize.getCurrentUserId() != "" {
            CHCustomOptions.showLogoutButton = true
            ChUI.launchChannelize(navigationController: self.navigationController)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isMovingToParent {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loginAccounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = loginAccounts[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loginMail = loginAccounts[indexPath.row]
        showProgressView(superView: self.navigationController?.view, string: nil)
        Channelize.login(email: loginMail, password: "123456", completion: {(user,errorString) in
            disMissProgressView()
            guard errorString == nil else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                return
            }
            CHCustomOptions.showLogoutButton = true
            ChUI.launchChannelize(navigationController: self.navigationController)
        })
    }
}


