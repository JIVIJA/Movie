//
//  Constants.swift
//  Movie
//
//  Created by mac-0007 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import Foundation
import UIKit

let CMainScreen = UIScreen.main
let CBounds = CMainScreen.bounds

let CScreenSize = CBounds.size
let CScreenWidth = CScreenSize.width
let CScreenHeight = CScreenSize.height

let CScreenOrigin = CBounds.origin
let CScreenX = CScreenOrigin.x
let CScreenY = CScreenOrigin.y

let CScreenCenter = CGPoint(x: CScreenWidth/2.0, y: CScreenHeight/2.0)
let CScreenCenterX = CScreenCenter.x
let CScreenCenterY = CScreenCenter.y

let CSharedApplication = UIApplication.shared
let CAppdelegate = CSharedApplication.delegate as? AppDelegate

let CUserDefaults = UserDefaults.standard

func CRGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

func CRGBA(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

let CGCDMainThread = DispatchQueue.main
