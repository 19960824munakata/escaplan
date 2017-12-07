//
//  CustamTextView.swift
//  escaplan
//
//  Created by むなかた　しゅん on 2017/11/26.
//  Copyright © 2017年 Koutya. All rights reserved.
//

import UIKit

class PlaceHolderTextView: UITextView {
    
    var placeHolderLabel: UILabel = UILabel()
    var placeHolderColor: UIColor = UIColor.lightGray
    var placeHolder: NSString = ""
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }   //  init?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }   //  deinit
    
    override public func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }   //  awakeFromNib
    
    override public func draw(_ rect: CGRect) {
        if(self.placeHolder.length > 0) {
            self.placeHolderLabel.frame = CGRect(x: 8, y: 8, width: self.bounds.size.width, height: 0)
            self.placeHolderLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.placeHolderLabel.numberOfLines = 0
            self.placeHolderLabel.font = self.font
            self.placeHolderLabel.backgroundColor = UIColor.clear
            self.placeHolderLabel.textColor = self.placeHolderColor
            self.placeHolderLabel.alpha = 0
            self.placeHolderLabel.tag = 1
            self.placeHolderLabel.text = self.placeHolder as String
            self.placeHolderLabel.sizeToFit()
            self.addSubview(placeHolderLabel)
        }   //  if
        self.sendSubview(toBack: placeHolderLabel)
        if self.text.utf16.count == 0 && self.placeHolder.length > 0 {
            self.viewWithTag(1)?.alpha = 1
        }   //  if
        super.draw(rect)
    }   //  draw
    public func textChanged(notification: NSNotification?) -> Void {
        if self.placeHolder.length == 0 {
            return
        }   //  if
        if self.text.utf16.count == 0 {
            self.viewWithTag(1)?.alpha = 1
        }else {
            self.viewWithTag(1)?.alpha = 0
        }   //  if
    }   //  textChange
}
