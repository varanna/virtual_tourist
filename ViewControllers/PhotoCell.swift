//
//  PhotoCell.swift
//  virtual_tourist
//
//  Created by Varosyan, Anna on 07.10.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    // Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.kf.indicatorType = .activity
    }
}
