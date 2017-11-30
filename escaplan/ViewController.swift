//
//  ViewController.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/10/05.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginTouch(_ sender: Any) {
        Twitter.sharedInstance().logIn { session, error in
            guard let session = session else {
                if let error = error {
                    print("エラーが起きました => \(error.localizedDescription)")
                }
                return
            }
            print("@\(session.userName)でログインしました")
            let View = self.storyboard!.instantiateViewController(withIdentifier: "calendarPage")
            self.present(View,animated: true,completion:nil)
        }
    }
    

}

