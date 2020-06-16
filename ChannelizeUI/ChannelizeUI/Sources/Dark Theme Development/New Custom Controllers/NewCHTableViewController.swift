//
//  NewCHTableViewController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import Reachability

class NewCHTableViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    let reachability = try! Reachability()
    
    var extraInfoContainerView: UIView = {
       let view = UIView()
       view.translatesAutoresizingMaskIntoConstraints = false
       view.backgroundColor = UIColor.systemTeal
       return view
    }()
    
    var bottomStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        return view
    }()
    
    var tableView: UITableView!
    
    private var extraInfoContainerHeightConstraint: NSLayoutConstraint!
    private var bottomStackHeightConstraint: NSLayoutConstraint!
    
    var extraInfoContainerViewHeight: CGFloat = 0.0 {
        didSet {
            UIView.animate(withDuration: 0.33, delay: 0.0, options: [.layoutSubviews], animations: {
                self.extraInfoContainerHeightConstraint.constant = self.extraInfoContainerViewHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    var bottomStackViewHeight: CGFloat = 0.0 {
        didSet {
            UIView.animate(withDuration: 0.33, delay: 0.0, options: [.layoutSubviews], animations: {
                self.bottomStackHeightConstraint.constant = self.bottomStackViewHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    
    init(tableStyle: UITableView.Style) {
        super.init(nibName: nil, bundle: nil)
        self.tableView = UITableView(frame: .zero, style: tableStyle)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        if self.tableView.style == .grouped {
            self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.groupedTableBackGroundColor : CHLightThemeColors.instance.groupedTableBackGroundColor
        } else {
            self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        }
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor.black : UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .white
        self.view.addSubview(extraInfoContainerView)
        self.view.addSubview(self.bottomStackView)
        self.view.addSubview(self.tableView)
        
        self.extraInfoContainerView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.extraInfoContainerView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.extraInfoContainerView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.extraInfoContainerHeightConstraint = NSLayoutConstraint(item: self.extraInfoContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        self.extraInfoContainerHeightConstraint.isActive = true
        self.view.addConstraint(self.extraInfoContainerHeightConstraint)
        
        self.bottomStackView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.bottomStackView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.bottomStackView.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        self.bottomStackHeightConstraint = NSLayoutConstraint(item: self.bottomStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        self.bottomStackHeightConstraint.isActive = true
        self.view.addConstraint(self.bottomStackHeightConstraint)
        
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setTopAnchor(relatedConstraint: self.extraInfoContainerView.bottomAnchor, constant: 0)
        self.tableView.setBottomAnchor(relatedConstraint: self.bottomStackView.topAnchor, constant: 0)
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //self.tableView.backgroundColor = CHUIConstants.conversationScreenBackgroundColor
        self.tableView.tableFooterView = UIView()
        //self.tableView.register(RecentConversationCell.self, forCellReuseIdentifier: "conversationCell")
        
        self.setNavigationColor()
        // Do any additional setup after loading the view.
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                self.extraInfoContainerView.viewWithTag(40058)?.removeFromSuperview()
                self.extraInfoContainerViewHeight = 0
            } else {
                self.extraInfoContainerView.viewWithTag(40058)?.removeFromSuperview()
                self.extraInfoContainerViewHeight = 0
            }
        }
        reachability.whenUnreachable = { _ in
            let noInternetLabel = UILabel()
            noInternetLabel.translatesAutoresizingMaskIntoConstraints = false
            noInternetLabel.backgroundColor = UIColor.systemRed
            noInternetLabel.textColor = UIColor.white
            noInternetLabel.font = CHCustomStyles.mediumSizeMediumFont
            noInternetLabel.text = "No Internet Connection."
            noInternetLabel.tag = 40058
            noInternetLabel.textAlignment = .center
            self.extraInfoContainerView.addSubview(noInternetLabel)
            noInternetLabel.pinEdgeToSuperView(superView: self.extraInfoContainerView)
            self.extraInfoContainerViewHeight = 35
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: - UIView Related Functions
    func setNavigationColor(animated: Bool = false) {
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.addTopBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor, andWidth: 0.5)
        var tintColor: UIColor?
        var imageColor: UIColor = UIColor(hex: "#1c1c1c")
        if CHAppConstant.themeStyle == .dark {
            tintColor = CHDarkThemeColors.instance.buttonTintColor
            imageColor = UIColor(hex: "#1c1c1c")
        } else {
            tintColor = CHLightThemeColors.instance.buttonTintColor
            imageColor = UIColor(hex: "#ffffff")
        }
        
        let animation = CATransition()
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.type = CATransitionType.fade

        if animated {
            navigationController?.navigationBar.layer.add(animation, forKey: nil)
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
                self.navigationController?.navigationBar.setBackgroundImage(imageColor.imageWithColor(width: self.view.frame.width, height: self.navigationController?.navigationBar.frame.size.height ?? 0), for: .default)
                getKeyWindow()?.tintColor = tintColor
            }, completion: nil)
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(imageColor.imageWithColor(width: self.view.frame.width, height: self.navigationController?.navigationBar.frame.size.height ?? 0), for: .default)
            getKeyWindow()?.tintColor = tintColor
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a"), NSAttributedString.Key.font: CHCustomStyles.normalSizeRegularFont!]
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor
        self.tableView.separatorStyle = .singleLine
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.tableView.reloadData()
        
        self.tabBarController?.tabBar.barTintColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.systemBlue
        //self.tabBarController?.tabBar.backgroundImage = UIColor(hex: "#1c1c1c").imageWithColor(width: self.view.frame.width, height: self.navigationController?.navigationBar.frame.size.height ?? 0)
        
    }
}
