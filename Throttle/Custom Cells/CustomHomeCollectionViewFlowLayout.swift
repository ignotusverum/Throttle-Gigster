//
//  CustomHomeCollectionViewFlowLayout.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/18/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class CustomHomeCollectionViewFlowLayout: UICollectionViewFlowLayout {
	let padding : CGFloat = 5;
	let numberOfColumns : CGFloat = 3;
	
	override init() {
		super.init()
		setupLayout()
	}
	
	override var itemSize: CGSize {
		set {
			
		}
		get {
			let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (numberOfColumns - 1)) / numberOfColumns
			return CGSizeMake(itemWidth - padding, itemWidth - padding)
		}
	}
 
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupLayout()
	}
 
	func setupLayout() {
		minimumInteritemSpacing = padding;
		minimumLineSpacing = padding * 2;
		scrollDirection = .Vertical;
	}
}
