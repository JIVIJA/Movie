//
//  ParentVC.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit
import RxSwift

class ParentVC: UIViewController {

    var iObject: Any?
    var handler: ((Any, Bool) -> ())?
    let disposeBag = DisposeBag()
    
    
    //MARK:-
    //MARK:- UIStatusBar
    var isStatusBarHide = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var statusBarStyle = UIStatusBarStyle.default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHide
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    //MARK:-
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch self.view.tag {
        case 100:
            statusBarStyle = .lightContent
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.barTintColor = CRGB(r: 30, g: 42, b: 81)
        default:
            statusBarStyle = .default
            break
        }
    }
    
    
    //MARK:-
    //MARK:- General Methods
    private func configure() {
        
    }

}
