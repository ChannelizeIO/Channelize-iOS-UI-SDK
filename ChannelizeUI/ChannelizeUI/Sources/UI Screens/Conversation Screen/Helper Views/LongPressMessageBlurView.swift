//
//  LongPressMessageBlurView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/10/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

protocol LongPressMessageBlurViewDelegate {
    func didSelectReplyMessage(messageId: String)
    func didSelectForwardMessage(messageId: String)
    func didSelectDeleteMessage(messageId: String)
    func didSelectMoreAction(messageId: String)
    func didSelectLongPressAction(messageId: String, actionType: LongPressOptionActionType)
}

class LongPressMessageBlurView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var visualEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: effect)
        return visualEffectView
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    var messageId: String!
    var delegate: LongPressMessageBlurViewDelegate?
    
    var actions = [LongPressOptionModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(selfOnTap(gesture:)))
        tapgesture.delegate = self
        tapgesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapgesture)
        self.setUpViews()
        //self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func selfOnTap(gesture: UIGestureRecognizer) {
        self.removeFromSuperview()
    }
    
    private func setUpViews() {
        self.addSubview(visualEffectView)
        self.addSubview(tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.masksToBounds = true
        self.tableView.isScrollEnabled = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.layer.cornerRadius = 15
        self.tableView.tableFooterView = UIView()
        self.tableView.register(SelectedMessageOptionCell.self, forCellReuseIdentifier: "optionCell")
        
    }
    
    private func setUpViewsFrames() {
        self.visualEffectView.frame.origin = .zero
        self.visualEffectView.frame.size = self.frame.size
        //self.visualEffectView.pinEdgeToSuperView(superView: self)
    }
    
    func insertSelectedMessage(view: UIView, viewHeight: CGFloat) {
        self.setUpViewsFrames()
        self.visualEffectView.contentView.addSubview(view)
        self.visualEffectView.contentView.addSubview(self.tableView)
        
        view.frame.origin.y = 20
        view.center.x = self.visualEffectView.contentView.frame.width/2
        view.frame.size.width = self.visualEffectView.contentView.frame.width
        view.frame.size.height = viewHeight
        
        self.tableView.frame.size.height = 200
        self.tableView.frame.size.width = 230
        self.tableView.frame.origin.x = self.visualEffectView.frame.width - self.tableView.frame.width - 15
        self.tableView.frame.origin.y = view.frame.origin.y + view.frame.height + 10
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
    }
    
    func assignActions(actions: [LongPressOptionModel]) {
        self.actions = actions
        self.tableView.reloadData()
    }
    
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! SelectedMessageOptionCell
        cell.selectionStyle = .none
        let action = self.actions[indexPath.row]
        switch action.actionType ?? .undefined {
        case .delete:
            cell.assignData(optionName: "Delete", icon: action.actionType?.rawValue, tintColor: UIColor.customSystemRed)
            break
        case .reply:
            cell.assignData(optionName: "Reply", icon: action.actionType?.rawValue, tintColor: .black)
            break
        case .forward:
            cell.assignData(optionName: "Forward", icon: action.actionType?.rawValue, tintColor: UIColor.black)
            break
        case .more:
            cell.assignData(optionName: "More", icon: action.actionType?.rawValue, tintColor: .black)
            break
        case .deleteAll:
            cell.assignData(optionName: "Delete All", icon: LongPressOptionActionType.delete.rawValue, tintColor: UIColor.customSystemRed)
            break
        case .forwardAll:
            cell.assignData(optionName: "Forward All", icon: LongPressOptionActionType.forward.rawValue, tintColor: UIColor.customSystemBlue)
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath)
        let action = self.actions[indexPath.row]
        self.delegate?.didSelectLongPressAction(messageId: self.messageId, actionType: action.actionType ?? .undefined)
        self.removeFromSuperview()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if touchView.isDescendant(of: self.tableView) {
                return false
            }
        }
        return true
    }
}

