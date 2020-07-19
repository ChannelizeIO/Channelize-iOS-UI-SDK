//
//  ReactionView.swift
//  ChannelizeUI
//
//  Created by bigstep on 5/8/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

class ReactionView: UIView{
    
    var reactions = [ReactionModel]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = .black
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func assignReactions(reactions: [ReactionModel]) {
        self.reactions = reactions
        self.subviews.forEach({
            $0.removeFromSuperview()
        })
        self.setUpViews()
    }
    
    func setUpViews() {
        var initialOriginX: CGFloat = 5
        var initialOriginY: CGFloat = 2.5
        //let selfWidth = self.view.frame.width
        self.reactions.forEach({
            let reaction = $0
            let view = ReactionButton()
            if reaction.counts == 1 {
                view.frame.size = CGSize(width: 30, height: 30)
            } else {
                let emojiString = reaction.unicode ?? ""
                let emojiWidth = emojiString.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 20.0, weight: .medium))
                let count = reaction.counts ?? 0
                let countsWidth = "\(count)".width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 20.0, weight: .regular))
                let totalWidth = 2.5 + emojiWidth + 2.5 + countsWidth + 2.5
                view.frame.size = CGSize(width: totalWidth, height: 30)
            }
            if initialOriginX + view.frame.width < self.frame.width - 2.5{
                print(" Same Line \(reaction.counts ?? 0)")
                view.frame.origin.x = initialOriginX
                view.frame.origin.y = initialOriginY
                initialOriginX = initialOriginX + view.frame.width + 5
            } else {
                print(" Different Line \(reaction.counts ?? 0)")
                initialOriginY += 32.5
                view.frame.origin.x = 5
                view.frame.origin.y = initialOriginY
                initialOriginX = 5 + view.frame.width + 5
            }
            view.reactionModel = reaction
            self.addSubview(view)
        })
    }
}

class ReactionButton: UIControl {
    
    private var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.backgroundColor = .clear
        return label
    }()
    
    private var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        label.textColor = UIColor.black
        return label
    }()
    
    var reactionModel: ReactionModel? {
        didSet{
            self.setUpViewsFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.init(white: 0.80, alpha: 1.0).cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.init(white: 0.98, alpha: 1.0)
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(emojiLabel)
        self.addSubview(countLabel)
    }
    
    private func setUpViewsFrames() {
        guard let data = self.reactionModel else {
            return
        }
        self.layer.masksToBounds = true
        if data.counts == 1 {
            self.layer.cornerRadius = self.frame.size.height/2
            self.emojiLabel.frame.size = self.frame.size
            self.emojiLabel.frame.origin = .zero
            self.countLabel.frame.size = .zero
            self.countLabel.frame.origin = .zero
        } else {
            self.layer.cornerRadius = 10
            let emojiString = data.unicode ?? ""
            let emojiWidth = emojiString.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 20.0, weight: .medium))
            self.emojiLabel.frame.size = CGSize(width: emojiWidth, height: self.frame.size.height)
            self.emojiLabel.frame.origin.x = 2.5
            self.emojiLabel.frame.origin.y = 0
            
            let count = data.counts ?? 0
            let countsWidth = "\(count)".width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 15.0, weight: .regular))
            self.countLabel.frame.size = CGSize(width: countsWidth, height: self.frame.size.height)
            self.countLabel.frame.origin.x = self.emojiLabel.frame.origin.x + self.emojiLabel.frame.size.width
            self.countLabel.frame.origin.y = 0
        }
        self.assignData(model: data)
    }
    
    private func assignData(model: ReactionModel) {
        self.emojiLabel.text = model.unicode
        self.countLabel.text = "\(model.counts ?? 0)"
    }
}

