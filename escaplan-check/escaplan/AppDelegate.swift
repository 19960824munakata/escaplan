//
//  AppDelegate.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/10/05.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import NCMB
import UserNotificationsUI
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let applicationkey = "5a2c96d04c8fc67d8c4653423a09ff36eedb89a686132ee8dd1aab871f8557ab"
    let clientkey      = "9848d560daa19d869b52cc5bb9ef1c6accb9a3eae6e30ec2f9a5303d38e92d41"
    var backgroundTaskID : UIBackgroundTaskIdentifier = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]){ (granted,error) in
            if granted{
                print("許可")
                UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            }else{
                print("不可")
            }
        }
        
        //mBaas
        NCMB.setApplicationKey(applicationkey, clientKey: clientkey)
        // デバイストークンの要求
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
    Twitter.sharedInstance().start(withConsumerKey:"ypqNM52r27MMONEf3CagWvMYe",consumerSecret:"QOGNIE99BdTj9zsjS3EaYqk0OIXNwj1qvF5A0fylw9U7SCp0a8")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if Twitter.sharedInstance().application(app, open: url, options: options){
            return true
        }
        return false
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        musical.audioPlayerInstance.play()
        let realm = try! Realm()

        let calendar = Calendar.current
        let date = Date()
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        print(comps.year!, comps.month!, comps.day!, comps.hour!, comps.minute!, comps.second!)
        var clientError: NSError?
        let session = Twitter.sharedInstance().sessionStore.session()?.userID
        let apiClient = TWTRAPIClient(userID: session)
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
        let now = String(comps.year!)+"年"+String(comps.month!)+"月"+String(comps.day!)+"日"+String(comps.hour!)+":"+String(comps.minute!)+":"+String(comps.second!)
        let params = ["status": (String(now) + "中間発表テスト")]
        let request = apiClient.urlRequest(withMethod: "POST", url: statusesShowEndpoint, parameters: params, error: &clientError)
        let d = String(comps.year!)+String(comps.month!)+String(comps.day!)
        let data = realm.object(ofType: calendarPlan.self, forPrimaryKey: d)
        if (data != nil && data?.plan != nil && data?.plan != ""){
            musical.audioPlayerInstance.stop()
        }else{
            apiClient.sendTwitterRequest(request) { (response, responseData, error) -> Void in
                if let err = error {
                    print("Error: \(err.localizedDescription)")
                    let push = NCMBPush()
                    let data_iOS = ["contentAvailable" : true] as [String : Any]
                    push.setData(data_iOS)
                    push.setPushToIOS(true)
                    push.setImmediateDeliveryFlag(true) // 即時配信
                    push.sendInBackground { (er) in
                        if error != nil {
                            // プッシュ通知登録に失敗した場合の処理
                            print("NG:\(er)")
                            completionHandler(.newData)
                        } else {
                            // プッシュ通知登録に成功した場合の処理
                            print("OK")
                            completionHandler(.newData)
                        }
                        musical.audioPlayerInstance.stop()
                    }
                    
                } else {
                    print("The first Tweet: \(String(describing: responseData))")
                    completionHandler(.newData)
                    musical.audioPlayerInstance.stop()
                }
            }
        }
        
    }
    
    // Remote Notification のエラーを受け取る
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    // Remote Notification の device token を表示
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //mBaas
        // 端末情報を扱うNCMBInstallationのインスタンスを作成
        let installation = NCMBInstallation.current()
        // デバイストークンの設定
        installation?.setDeviceTokenFrom(deviceToken as Data!)
        // 端末情報をデータストアに登録
        installation?.saveInBackground { (error) -> Void in
            if (error != nil){
                // 端末情報の登録に失敗した時の処理
                if ((error! as NSError).code == 409001){
                    // 失敗した原因がデバイストークンの重複だった場合
                    // 端末情報を上書き保存する
                    self.updateExistInstallation(currentInstallation: installation!)
                }else{
                    // デバイストークンの重複以外のエラーが返ってきた場合
                }
            }else{
                // 端末情報の登録に成功した時の処理
            }
        }
    }
    
    //mBaas
    // 端末情報を上書き保存するupdateExistInstallationメソッドを用意
    func updateExistInstallation(currentInstallation : NCMBInstallation){
        let installationQuery: NCMBQuery = NCMBInstallation.query()
        installationQuery.whereKey("deviceToken", equalTo:currentInstallation.deviceToken)
        do {
            let searchDevice = try installationQuery.getFirstObject()
            // 端末情報の検索に成功した場合
            // 上書き保存する
            currentInstallation.objectId = (searchDevice as AnyObject).objectId
            currentInstallation.saveInBackground { (error) -> Void in
                if (error != nil){
                    // 端末情報の登録に失敗した時の処理
                }else{
                    // 端末情報の登録に成功した時の処理
                }
            }
        } catch _ as NSError {
            // 端末情報の検索に失敗した場合の処理
        }
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "escaplan")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

