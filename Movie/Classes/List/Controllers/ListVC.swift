//
//  ListVC.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit

class ListVC: ParentVC {

    @IBOutlet fileprivate weak var btnNowShowing: UIButton!
    @IBOutlet fileprivate weak var btnComingSoon: UIButton!
    @IBOutlet fileprivate weak var cnstLeadingSelectedType: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tblMovies: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK:- General Methods
    func initialize() {
        
    }
}
