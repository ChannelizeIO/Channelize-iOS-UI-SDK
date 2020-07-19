//
//  CHCollectionView+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

extension UICollectionView {
    func scrollToLast(animated: Bool = true, position: UICollectionView.ScrollPosition = .bottom) {
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: position, animated: animated)
    }
    
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void,
        completion: (() -> Void)? = nil
        ) {
        if stagedChangeset.isEmpty {
            completion?()
            return
        }
        
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            reloadData()
            DispatchQueue.main.async {
                completion?()
            }
            return
        }

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                reloadData()
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            performBatchUpdates({
                setData(changeset.data)

                if !changeset.sectionDeleted.isEmpty {
                    deleteSections(IndexSet(changeset.sectionDeleted))
                }

                if !changeset.sectionInserted.isEmpty {
                    insertSections(IndexSet(changeset.sectionInserted))
                }

                if !changeset.sectionUpdated.isEmpty {
                    reloadSections(IndexSet(changeset.sectionUpdated))
                }

                for (source, target) in changeset.sectionMoved {
                    moveSection(source, toSection: target)
                }

                if !changeset.elementDeleted.isEmpty {
                    deleteItems(at: changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
                }

                if !changeset.elementInserted.isEmpty {
                    insertItems(at: changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
                }

                if !changeset.elementUpdated.isEmpty {
                    reloadItems(at: changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) })
                }

                for (source, target) in changeset.elementMoved {
                    moveItem(at: IndexPath(item: source.element, section: source.section), to: IndexPath(item: target.element, section: target.section))
                }
            }, completion: {(completed) in
                completion?()
            })
        }
    }
}


