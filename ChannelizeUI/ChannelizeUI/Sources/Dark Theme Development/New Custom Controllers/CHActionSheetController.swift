//
//  CHActionSheetController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/4/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
class CHActionSheetAction {
    
    enum CHActionType {
        case `default`
        case destructive
        case cancel
    }
    
    var actionType: CHActionType
    var title: String?
    var handler: ((CHActionSheetAction) -> Void)?
    var image: UIImage?
    init(title: String?, image: UIImage?, actionType: CHActionSheetAction.CHActionType, handler: ((CHActionSheetAction) ->Void)?) {
        self.title = title
        self.actionType = actionType
        self.handler = handler
        self.image = image
    }
    
    func didPress() {
        self.handler?(self)
    }
    
}

class CHActionSheetController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        button.setTitle(CHLocalized(key: "pmCancel"), for: .normal)
        button.setTitleColor(CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(fontStyle: .medium, size: 20.0)
        return button
    }()
    
    var alertContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c").withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(0.9)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var visualEffectView: UIVisualEffectView = {
        let effect = CHAppConstant.themeStyle == .dark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .regular)
        let visualEffect = UIVisualEffectView(effect: effect)
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        return visualEffect
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        return tableView
    }()
    
    var actions = [CHActionSheetAction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.view.addSubview(cancelButton)
        self.cancelButton.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 10)
        self.cancelButton.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: -10)
        self.cancelButton.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        self.cancelButton.setHeightAnchor(constant: 55)
        self.cancelButton.layer.cornerRadius = 10
        
        self.view.addSubview(alertContainerView)
        self.alertContainerView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 10)
        self.alertContainerView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: -10)
        self.alertContainerView.setBottomAnchor(relatedConstraint: self.cancelButton.topAnchor, constant: -10)
        self.alertContainerView.setHeightAnchor(constant: CGFloat(actions.count * 55))
        
        self.alertContainerView.addSubview(visualEffectView)
        self.visualEffectView.pinEdgeToSuperView(superView: self.alertContainerView)
        self.visualEffectView.contentView.addSubview(self.tableView)
        self.tableView.pinEdgeToSuperView(superView: self.visualEffectView.contentView)
        
        //self.view.addSubview(tableView)
        //self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 10)
        //self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: -10)
        //self.tableView.setBottomAnchor(relatedConstraint: self.cancelButton.topAnchor, constant: -10)
        //self.tableView.setHeightAnchor(constant: CGFloat(actions.count * 55))
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset.top = 0
        self.tableView.contentInset.bottom = 0
        self.tableView.isScrollEnabled = false
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#38383a") : UIColor(hex: "#c6c6c8")
        
        self.cancelButton.addTarget(self, action: #selector(cancelButtonPressed(sender:)), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func cancelButtonPressed(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let action = self.actions[indexPath.row]
        cell.textLabel?.text = self.actions[indexPath.row].title
        cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        cell.textLabel?.textColor = action.actionType == .destructive ? UIColor.customSystemRed : (CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor)
        cell.textLabel?.font = UIFont(fontStyle: .regular, size: 18.0)
        cell.imageView?.image = self.actions[indexPath.row].image
        cell.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.buttonTintColor : CHLightThemeColors.instance.buttonTintColor
        cell.textLabel?.textAlignment = .center
        cell.separatorInset.left = 0
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let action = self.actions[indexPath.row]
        self.dismiss(animated: true, completion: {
            action.didPress()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                
            })
        })
        //action.didPress()
        //self.dismiss(animated: true, completion: nil)
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


