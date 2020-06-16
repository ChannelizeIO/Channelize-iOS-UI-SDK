//
//  CHAlertViewController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/6/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit

class CHAlertViewController: UIViewController {

    var alertTitle: String?
    var alertDescription: String?
    var textFields = [UITextField]()
    var actions = [CHActionSheetAction]()
    
    var alertContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c").withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(1.0)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    var visualEffectView: UIVisualEffectView = {
        let effect = CHAppConstant.themeStyle == .dark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
        let visualEffect = UIVisualEffectView(effect: effect)
        visualEffect.backgroundColor = CHAppConstant.themeStyle == .dark ? .clear : UIColor.white
        return visualEffect
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(alertContainerView)
        self.alertContainerView.frame.size = CGSize(width: 280, height: 350)
        self.alertContainerView.center.y = self.view.center.y
        self.alertContainerView.center.x = self.view.center.x
        
        self.alertContainerView.addSubview(visualEffectView)
        self.visualEffectView.frame.origin = .zero
        self.visualEffectView.frame.size.width = 280
        self.visualEffectView.frame.size.height = 0
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if alertTitle != nil && alertTitle != "" {
            let titlesAttributes: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.font: UIFont(fontStyle: .medium, size: 17.0)!, NSAttributedString.Key.foregroundColor: CHUIConstant.recentConversationTitleColor]
            let labelHeight = getAttributedLabelHeight(attributedString: NSAttributedString(string: alertTitle ?? "", attributes: titlesAttributes), maximumWidth: 250)
            self.titleLabel.frame.size = CGSize(width: 260, height: labelHeight + 5)
            self.titleLabel.frame.origin.x = 10
            self.titleLabel.frame.origin.y = 10
            self.visualEffectView.contentView.addSubview(self.titleLabel)
            self.titleLabel.attributedText = NSAttributedString(string: alertTitle ?? "", attributes: titlesAttributes)
        } else {
            self.titleLabel.frame.size = .zero
            self.titleLabel.frame.origin = CGPoint(x: 5, y: 5)
        }
        
        if alertDescription != nil && alertDescription != "" {
            let descriptionAttributes: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 15.0)!, NSAttributedString.Key.foregroundColor: CHUIConstant.recentConversationMessageColor]
            let labelHeight = getAttributedLabelHeight(attributedString: NSAttributedString(string: alertDescription ?? "", attributes: descriptionAttributes), maximumWidth: 250)
            self.descriptionLabel.frame.size = CGSize(width: 260, height: labelHeight + 5)
            self.descriptionLabel.frame.origin.x = 10
            self.descriptionLabel.frame.origin.y = getViewEndOriginY(view: self.titleLabel)
            self.visualEffectView.contentView.addSubview(self.descriptionLabel)
            self.descriptionLabel.attributedText = NSAttributedString(string: alertDescription ?? "", attributes: descriptionAttributes)
        } else {
            self.descriptionLabel.frame.size = .zero
            self.descriptionLabel.frame.origin.x = 10
            self.descriptionLabel.frame.origin.y = getViewEndOriginY(view: self.titleLabel)
        }
        
        if textFields.count > 0 {
            textFields.forEach({
                self.visualEffectView.contentView.addSubview($0)
                $0.frame.size = CGSize(width: 250, height: 40)
                $0.frame.origin.x = 15
                $0.frame.origin.y = getViewEndOriginY(view: self.descriptionLabel) + 10
            })
        }
        
        let enumeratedActions = self.actions.enumerated()
        for(index,action) in enumeratedActions {
            let button = UIButton()
            button.setTitle(action.title, for: .normal)
            button.titleLabel?.font = UIFont(fontStyle: .medium, size: 17.0)
            if action.actionType == .destructive {
                button.setTitleColor(UIColor.customSystemRed, for: .normal)
            } else {
                button.setTitleColor(CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor, for: .normal)
            }
            button.titleLabel?.textAlignment = .center
            button.backgroundColor = .clear
            button.tag = 5000*(index+1)
            self.visualEffectView.contentView.addSubview(button)
            button.frame.size = CGSize(width: 280, height: 50)
            button.frame.origin.x = 0
            button.frame.origin.y = getViewEndOriginY(view: self.descriptionLabel) + CGFloat((textFields.count * 40)) + (textFields.count > 0 ? 20 : 0) + CGFloat((index * 50)) + 10
            button.addTopBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 1.0)
            button.addTarget(self, action: #selector(actionButtonPressed(sender:)), for: .touchUpInside)
        }
        self.alertContainerView.frame.size.height = getViewEndOriginY(view: self.descriptionLabel) + CGFloat((textFields.count * 40)) + (textFields.count > 0 ? 20 : 0) + CGFloat((actions.count * 50)) + 10
        self.visualEffectView.frame.size.height = self.alertContainerView.frame.size.height
        if self.textFields.count > 0 {
            self.textFields.first?.becomeFirstResponder()
        }
        self.alertContainerView.center.y = self.view.center.y
        self.alertContainerView.center.x = self.view.center.x
    }
    
    @objc func actionButtonPressed(sender: UIButton) {
        let tag = sender.tag/5000
        let index = tag - 1
        let action = self.actions[index]
        if action.actionType == .cancel {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: {
                action.didPress()
            })
        }
    }
    
    func addTextField(configuration: ((UITextField)->Void)?) {
        let textField = UITextField()
        textField.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#e6e6e6")
        textField.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        textField.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 7.5
        textField.rightViewMode = .always
        //textField.textAlignment = .center
        textField.keyboardAppearance = CHAppConstant.themeStyle == .dark ? .dark : .light
        textField.font = UIFont(fontStyle: .regular, size: 16.0)
        textField.setLeftPadding(withPadding: 15)
        self.textFields.append(textField)
        configuration?(textField)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.alertContainerView.center = self.view.center
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

