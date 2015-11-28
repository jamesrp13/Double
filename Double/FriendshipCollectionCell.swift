//
//  FriendshipCell.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class FriendshipCollectionCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var friendships: [Friendship] {
        return FriendshipController.SharedInstance.friendships
    }

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCollectionView", name: FriendshipController.kFriendshipsChanged, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCollectionView() {
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendships.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("friendshipCell", forIndexPath: indexPath) as? FriendshipCell {
            cell.updateWithFriendship(FriendshipController.SharedInstance.friendships[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }

}
