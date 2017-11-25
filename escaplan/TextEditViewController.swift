//
//  TextEditViewController.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/10/14.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import UIKit



class TextEditViewController: UIViewController {

    @IBOutlet weak var textfield: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 枠のカラー
        textfield.layer.borderColor = UIColor.black.cgColor
        
        // 枠の幅
        textfield.layer.borderWidth = 1.0
        textfield.text = "Sample"
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
