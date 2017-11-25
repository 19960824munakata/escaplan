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

class CalendarViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,UIGestureRecognizerDelegate,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    
    let tableTitle = [["今日の予定","hogehoge"]]

//    @IBOutlet weak var calendarHeightConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // FSCalendarのデリゲートの設定(おまじまい的な感じ?)
        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        print(getDay(calendar.today!))
        
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
    
    //カレンダータップイベント
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let d = getDay(date)
        print(String(d.0) + "年" + String(d.1) + "月" + String(d.2) + "日")
//        self.view.addGestureRecognizer(self.scopeGesture)
//      self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.setScope(.week, animated: true)
    }
    
    @IBAction func exampple(_ sender: Any) {

        popinit();
        
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitle[section].count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "myPlan")
        cell.textLabel?.text = tableTitle[indexPath.section][indexPath.row + 1]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableTitle.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableTitle[section][0]
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
