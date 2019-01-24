//
//  HomeCVCell.swift
//  Movie
//
//  Created by mac-00017 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit
import Kingfisher
class HomeCVCell: UICollectionViewCell {

    // MARK: -
    // MARK: - @IBOutlets.
    @IBOutlet fileprivate weak var btnBook: UIButton!
    @IBOutlet fileprivate weak var lblPreSale: UILabel!
    @IBOutlet fileprivate weak var imgPoster: UIImageView!
    @IBOutlet weak var cnBtnBookHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        lblPreSale.layer.cornerRadius = lblPreSale.frame.height/2.0
        lblPreSale.layer.masksToBounds = true
    }
}

extension HomeCVCell {
    func configureCell(movieModel: MovieModel) {
        
        if let presaleFlag = movieModel.presaleFlag {
            lblPreSale.isHidden = presaleFlag == 0
        }
        
        if let posterPath = movieModel.posterPath {
            imgPoster.kf.indicatorType = .activity
            imgPoster.kf.setImage(with: URL(string: posterPath))
        }
    }
}
