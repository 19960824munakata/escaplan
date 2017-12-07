//
//  PopUpView.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/10/14.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import Foundation
import UIKit


class PopUpView: UIView {
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var textfiledl: UITextView!
    
    
    @IBAction func edit(_ sender: Any) {
        self.removeFromSuperview()
    }

    
}
