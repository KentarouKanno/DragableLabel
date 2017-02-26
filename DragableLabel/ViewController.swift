//
//  ViewController.swift
//  DragableLabel
//
//  Created by Kentarou on 2017/02/26.
//  Copyright © 2017年 Kentarou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var baseView: DragableLabelBaseView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseView.wordArray = ["Swift!", "iPhone", "Apple", "Xcode", "Objective-C", "Swift!", "iPhone", "Apple", "Xcode", "Objective-C", "a", "abc"]
    }
}


class DragableLabelBaseView: UIView {
    
    let labelMargin: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    var words = [String]()
    
    var wordArray: [String]! {
        get {
            return words
        }
        set(words) {
            
            var lastLabelEndPoint_X: CGFloat = 0
            var lastLabelEndPoint_Y: CGFloat = 0
            
            for word in words {
                
                let label = DragableLabel(text: word)
                label.x = lastLabelEndPoint_X
                label.frame.origin.y = lastLabelEndPoint_Y
                
                if label.x + label.width > self.width {
                    
                    label.x = 0
                    label.frame.origin.y = label.y + label.height + labelMargin
                    lastLabelEndPoint_Y = label.y
                }
                
                self.addSubview(label)
                lastLabelEndPoint_X = label.x + label.width + labelMargin
            }
        }
    }
    
    func resetView() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func awakeFromNib() {
    
    }
}


class DragableLabel: UILabel {
    
    let labelHeight: CGFloat = 28
    
    var labelText: String? {
        get {
            return self.text
        }
        set(word) {
            
            self.text = word
            self.sizeToFit()
            frame = CGRect(x: 0, y: 0, width: self.frame.size.width + 25, height: labelHeight)
        }
    }

    
    init(text: String?) {
        super.init(frame: CGRect.zero)
        labelText = text
        labelSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func labelSetUp() {
        
        backgroundColor = #colorLiteral(red: 0.1654851139, green: 0.6282587051, blue: 0.831725657, alpha: 1)
        textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        
        textAlignment = .center
    }
}

extension UIView {
    
    var x: CGFloat {
        get { return frame.origin.x }
        set (x){ self.frame.origin.x = x }
    }
    
    var y: CGFloat {
        get { return frame.origin.y }
        set (y){ self.frame.origin.y = y }
    }
    
    var width: CGFloat {
        get { return frame.size.width }
        set(width) { self.frame.size.width = width }
    }
    
    var height: CGFloat {
        get { return frame.size.height }
        set(height) { self.frame.size.height = height }
    }
}

