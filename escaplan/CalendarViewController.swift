//
//  CalendarViewController.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/10/14.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class CalendarViewController: UIViewController,UIGestureRecognizerDelegate{

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var textView: PlaceHolderTextView!
    
    
    //予定がない時に表示する文字
    let dummyText : NSString = "予定なし"
    //選択した(タップした)日付の保存 :初期値は今日の日付
    var selectDay = ""
    //イベント画像添付判定に使用
    var didload = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // FSCalendarのデリゲートの設定(おまじまい的な感じ?)
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.textView.delegate = self
        let today = getDay(calendar.today!)
        dayLabel.text = String(today.1) + "月" + String(today.2) + "日の予定"
        selectDay = String(today.0)+String(today.1)+String(today.2)
        //Realmのインスタンスを取得
        let realm = try! Realm()
        //placeholderの設定
        textView.placeHolderColor = UIColor.lightGray
        textView.placeHolder = dummyText
        //データの有無
        let data = realm.object(ofType: calendarPlan.self, forPrimaryKey: selectDay)
        if (data != nil && data?.plan != nil){            //Realmから呼び出し
            //placeholdarラベルを透明化
            textView.placeHolderLabel.alpha = 0
            textView.text = data?.plan
        }else{
            //なければ
            textView.text = nil
            //placeholdarラベルを可視化
            textView.placeHolderLabel.alpha = 1
        }
        
        //完了ボタン、キャンセルボタンのview追加
        addToolBar(textView: textView,calendar: calendar)
        
        // Do any additional setup after loading the view.
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス(それ以外に用いない)
        let tmpCalendar = Calendar(identifier: .gregorian)
        
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    //曜日判定(土曜日:1 〜 日曜日:6)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }
        
        return nil
    }
    
    //予定がある日に画像を配置する
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let image:UIImage = UIImage(named:"100")!
        //初回かどうか
        switch didload{
        case 0:
            //初回起動時、カレンダー全ての日付に対して行う
            //予定があれば
            if eventCheck(date){
                return image
            }
        case 1:
            if selectEventCheck(date){
                return image
            }
        default:
            break
        }
        return nil
    }
    //予定があるかないか
    func eventCheck(_ date: Date) -> Bool {
        //カレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        //Realmのインスタンスを取得
        let realm = try! Realm()
        let d = String(year)+String(month)+String(day)
        let data = realm.object(ofType: calendarPlan.self, forPrimaryKey: d)
        if (data != nil && data?.plan != nil && data?.plan != ""){
            return true
        }else{
            return false
        }
    }
        
    func selectEventCheck(_ date:Date) ->Bool{
        let day = getDay(date)
        //Realmのインスタンスを取得
        let realm = try! Realm()
        let d = String(day.0)+String(day.1)+String(day.2)
        let data = realm.object(ofType: calendarPlan.self, forPrimaryKey: d)
        if (data != nil && data?.plan != nil && data?.plan != ""){
            return true
        }else{
            return false
        }
    }
    
    
    //カレンダータップイベント
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //Realmのインスタンスを取得
        let realm = try! Realm()
        let d = getDay(date)
        print(String(d.0) + "年" + String(d.1) + "月" + String(d.2) + "日")
        dayLabel.text = String(d.1) + "月" + String(d.2) + "日の予定"
        //キーボードをしまう
        if(textView.isFirstResponder){
            let add = calendarPlan()
            add.saveDay = selectDay
            add.plan = textView.text
            try! realm.write {
                realm.add(add,update: true)     //事前にデータがあれば更新する、なければ追加
            }
            textView.resignFirstResponder()
        }
        //カレンダーをmonthModeに
        calendar.setScope(.month, animated: true)
        
        selectDay = String(d.0)+String(d.1)+String(d.2)
        //データの有無
        let data = realm.object(ofType: calendarPlan.self, forPrimaryKey: selectDay)
        if (data != nil && data?.plan != nil && data?.plan != ""){
            //placeholdarラベルを透明化
            textView.placeHolderLabel.alpha = 0
            //Realmから呼び出し
            textView.text = data?.plan
        }else{
            //データがなければ
            textView.text = nil
            //placeholdarラベルを可視化
            textView.placeHolderLabel.alpha = 1
        }        
        
    }
    
    @IBAction func exampple(_ sender: Any) {
        popinit();
    }
    //calendarのサイズ調整
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func popinit() {
        //  カスタムポップアップ
        let popupView:PopUpView = UINib(nibName: "PopUpView", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! PopUpView
        // ポップアップビュー背景色（グレーの部分）
        let viewColor = UIColor.black
        // 半透明にして親ビューが見えるように。透過度はお好みで。
        popupView.backgroundColor = viewColor.withAlphaComponent(0.5)
        //To Do 通知内容によって質問内容を変える
        
        //To Do 機嫌によって回答内容を変える。
        
        // ポップアップビューを画面サイズに合わせる
        //       popupView.frame = self.view.frame
        // ダイアログ背景色（白の部分）
        let baseViewColor = UIColor.white
        // 背景を白に
        popupView.textView.backgroundColor = baseViewColor.withAlphaComponent(1.0)
        // 角丸にする
        popupView.textView.layer.cornerRadius = 8.0
        
        popupView.textfiledl.text = "Sample"
        // 貼り付ける
        self.view.addSubview(popupView)
    }
    
    //calendarView以外をタップした時
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //Realmのインスタンスを取得
        let realm = try! Realm()
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            //textView以外をタッチした時
            if tag != 123 {
                //キーボードをしまう
                if(textView.isFirstResponder){
                    let add = calendarPlan()
                    add.saveDay = selectDay
                    add.plan = textView.text
                    try! realm.write {
                        realm.add(add,update: true)     //事前にデータがあれば更新する、なければ追加
                    }
                    //calendarをmonthModeに
                    calendar.setScope(.month, animated: true)
                    textView.resignFirstResponder()
                }
            }

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver() // Notificationを画面が消えるときに削除
    }
    
    // Notificationを設定
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
 //       notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、calendarをweekModeにする
    func keyboardWillShow(notification: Notification?) {
        didload = 1
        calendar.setScope(.week, animated: true)
    }
    //キーボードが消える時にmonthMode
/*   func keyboardWillHide(notification: Notification?) {
        calendar.setScope(.month, animated: true)
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//キーボードに完了ボタン追加
extension CalendarViewController: UITextViewDelegate,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    func addToolBar(textView: UITextView,calendar: FSCalendar){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textView.delegate = self
        textView.inputAccessoryView = toolBar
    }
    @objc func donePressed(){
        //Realmのインスタンスを取得
        let realm = try! Realm()

        let add = calendarPlan()
        add.saveDay = selectDay
        add.plan = textView.text
        try! realm.write {
            realm.add(add,update: true)     //事前にデータがあれば更新する、なければ追加
        }
        calendar.setScope(.month, animated: true)
        view.endEditing(true)
    }
    @objc func cancelPressed(){

        let realm = try! Realm()
        //データの有無
        let data = realm.object(ofType: calendarPlan.self, forPrimaryKey: selectDay)
        if (data != nil && data?.plan != nil && data?.plan != ""){
            //placeholdarラベルを透明化
            textView.placeHolderLabel.alpha = 0
            textView.text = data?.plan
        }else{
            //なければ
            textView.text = nil
            //placeholdarラベルを可視化
            textView.placeHolderLabel.alpha = 1
        }
        calendar.setScope(.month, animated: true)
        view.endEditing(true) // or do something
    }
}
