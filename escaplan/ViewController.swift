//
//  ViewController.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/10/05.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var notificationLabel1: UILabel!
    @IBOutlet weak var notificationLabel2: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        if(userDefaults.integer(forKey:"twitterLoginCheck") == 1){
            loginButton.alpha = 1
            notificationLabel1.text = "このアプリはTwitterにログインしないと使用できません。"
            notificationLabel2.text = "下のボタンよりログインしてください。"
        }else{
            loginButton.alpha = 0
            notificationLabel1.text = "このアプリは通知をオンにしないと使用できません。"
            notificationLabel2.text = "通知をオンにした後、再起動をお願いします。"
        }
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

