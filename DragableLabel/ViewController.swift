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
    
    let words = ["Swift!", "iPhone", "Apple", "Xcode", "Objective-C", "WatchOS"] //, "iPadmini", "iOS", "MacbookPro", "LLVM", "AppleWatch", "Macbook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseView.words = words
    }
    
    // クリアボタン
    @IBAction func pushResetButton(_ sender: UIButton) {
        baseView.clearArray()
        baseView.words = words
    }
    
    @IBAction func pushJudgeButton(_ sender: UIButton) {
        
        baseView.checkAnswer()
    }
}


// MARK: - DragableLabelBaseView


class DragableLabelBaseView: UIView, DragableLabelDelegate {
    
    let labelMargin: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // 正解配列
    var answerArray   = [SortWord]()
    
    // 自分の回答配列
    var myAnswerArray = [SortWord]()
    // ランダム単語配列
    var wordArray     = [SortWord]()
    
    
    var currentWords = [String]()
    
    var words: [String]! {
        get {
            return []
        }
        
        set(words) {
            
            currentWords = words
            
            if wordArray.isEmpty {
                
                self.wordArray = words.enumerated().map {
                    let sortWord = SortWord(text: $0.element)
                    sortWord.isAnswerFlg = false
                    sortWord.index = $0.offset
                    return sortWord
                }
            }
            
            if answerArray.isEmpty {
                
                self.answerArray = words.enumerated().map {
                    let sortWord = SortWord(text: $0.element)
                    sortWord.isAnswerFlg = false
                    sortWord.index = $0.offset
                    return sortWord
                }
            }
            
            if myAnswerArray.isEmpty {
                self.myAnswerArray = words.enumerated().map {
                    let sortWord = SortWord(text: "   ")
                    sortWord.isAnswerFlg = true
                    sortWord.index = $0.offset
                    return sortWord
                }
            }
            
            setUpLabel()
        }
    }
    
    
    func setUpLabel() {
        
        resetView()
        
        myAnswerArray = myAnswerArray.enumerated().map {
            $0.element.index = $0.offset
            return $0.element
        }
        
        var answerLastLabelEndPoint_X: CGFloat = 0
        var answerLastLabelEndPoint_Y: CGFloat = 0
        
        for word in wordArray.enumerated() {
            
            let label = DragableLabel(sortWord: myAnswerArray[word.offset])
            label.delegate = self
            label.x = answerLastLabelEndPoint_X
            label.frame.origin.y = answerLastLabelEndPoint_Y
            
            if label.x + label.width > self.width {
                
                label.x = 0
                label.frame.origin.y = label.y + label.height + labelMargin
                answerLastLabelEndPoint_Y = label.y
            }
            
            self.addSubview(label)
            answerLastLabelEndPoint_X = label.x + label.width + labelMargin
        }
        
        
        var lastLabelEndPoint_X: CGFloat = 0
        var lastLabelEndPoint_Y: CGFloat = answerLastLabelEndPoint_Y + 100
        
        for word in wordArray.enumerated() {
            
            let label = DragableLabel(sortWord: wordArray[word.offset])
            label.delegate = self
            label.x = lastLabelEndPoint_X
            label.frame.origin.y = lastLabelEndPoint_Y
            
            if label.x + label.width > self.width {
                
                label.x = 0
                label.frame.origin.y = label.y + label.height + labelMargin
                lastLabelEndPoint_Y = label.y
            }
            
            //
            
            self.addSubview(label)
            lastLabelEndPoint_X = label.x + label.width + labelMargin
        }
    }
    
    func isDraggable(isDrag: Bool) {
        
    }
    
    
    func tapSentence(sortWord: SortWord) {
       upDateMyAnswer(sortWord: sortWord)
    }
    
    func upDateMyAnswer(sortWord: SortWord) {
        
        for word in myAnswerArray.enumerated() {
            if word.element.text == "   " {
                sortWord.isAlreadyAnswer = true
                
                let copySortWord = sortWord.copy()
                copySortWord.isAlreadyAnswer = true
                copySortWord.isAnswerFlg = true
                myAnswerArray[word.offset] = copySortWord
                setUpLabel()
                break
            }
        }
    }
    

    func resetView() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    func clearArray() {
        answerArray = []
        myAnswerArray = []
        wordArray = []
    }
    
    func labelMoveing(label: UILabel, position: CGPoint) {
        
        for view in self.subviews {
            
            
            
            if let label1 = view as? DragableLabel {
                
                guard label1.sortWord.isAnswerFlg else {
                    return
                }
                
                // if label1.frame.intersects(label.frame) {
                if label1.frame.contains(position) {
                    
                    //label1.addDashedBorder(boarderColor: .white)
                    label1.backgroundColor = UIColor.white
                    
                } else {
                    label1.labelSetUp()
                }
            }
        }
    }
    
    
    
    func labelMoveEnded(sortWord: SortWord, changedLabel: DragableLabel) {
    
        sortWord.isCorrectAnswer = true
        changedLabel.sortWord.isCorrectAnswer = true
        
        let tmp = myAnswerArray[changedLabel.sortWord.index].copy()
        
        if tmp.text == "   " {
            
            sortWord.isAlreadyAnswer = true
            
            let copySortWord = changedLabel.sortWord.copy()
            copySortWord.isAlreadyAnswer = true
            copySortWord.index = sortWord.index
            copySortWord.text = sortWord.text
            myAnswerArray[changedLabel.sortWord.index] = copySortWord
            
            if sortWord.isAnswerFlg {
                myAnswerArray[sortWord.index] = tmp
            }
            
        } else {
            
            sortWord.isAlreadyAnswer = true
            tmp.isAlreadyAnswer = true
            
            myAnswerArray[sortWord.index] = tmp
            myAnswerArray[changedLabel.sortWord.index] = sortWord
        }
        
        setUpLabel()
    }
    
    func checkAnswer() {
        
        for answer in answerArray.enumerated() {
            for myAnswer in myAnswerArray.enumerated() {
                
                if answer.offset == myAnswer.offset {
                    
                    if answer.element.text == myAnswer.element.text {
                        myAnswer.element.isCorrectAnswer = true
                    } else {
                        myAnswer.element.isCorrectAnswer = false
                    }
                }
            }
        }
        
        setUpLabel()
    }
}




// MARK: - DragableLabelDelegate

protocol DragableLabelDelegate: class {
    func isDraggable(isDrag: Bool)
    func tapSentence(sortWord: SortWord)
    
    /**
    ラベルをドラッグ中に呼ばれる
     - parameter label: ドラッグ中のラベル
     - parameter position: ドラッグ中の指の位置
 
    */
    func labelMoveing(label: UILabel, position: CGPoint)
    
    
    func labelMoveEnded(sortWord: SortWord, changedLabel: DragableLabel)
}

// MARK: - DragableLabel

class DragableLabel: UILabel {
    
    weak var delegate: DragableLabelDelegate?
    var sortWord: SortWord!
    
    let labelHeight: CGFloat = 28
    
    var dragLabel: UILabel!
    var location: CGPoint!

    
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
    
    var isAlreadyAnswer: Bool! {
        get {
            return false
        }
        set(value) {
            
            if !sortWord.isAnswerFlg {
                self.alpha = value! ? 0.3 : 1.0
            }
        }
    }

    
    init(sortWord: SortWord) {
        super.init(frame: CGRect.zero)
        
        self.sortWord = sortWord
        isAlreadyAnswer = sortWord.isAlreadyAnswer
        labelText = sortWord.text
        isUserInteractionEnabled = true
        labelSetUp()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapSentence))
        self.addGestureRecognizer(tapGesture)
    }
    
    func tapSentence() {
        
        guard !sortWord.isAlreadyAnswer else {
            return
        }
        
        guard !sortWord.isAnswerFlg else {
            return
        }
        
        delegate?.tapSentence(sortWord: self.sortWord)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func labelSetUp() {
        
        if sortWord.isAnswerFlg {
            
            if !sortWord.isCorrectAnswer {
                if sortWord.isAlreadyAnswer {
                    
                    failedAnswerLabel(label: self)
                } else {
                    failedNoAnswerLabel(label: self)
                }
                return
            }
            
            if sortWord.isAlreadyAnswer {
                
                answerLabel(label: self)
            } else {
                
                // 破線状態のラベルを作成
                noAnswerLabel(label: self)
            }
            
        } else {
            
            defaultSetting(label: self)
        }
    }
    
    func failedAnswerLabel(label: UILabel) {
        
        label.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = self.text
        label.textAlignment = .center
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
    }
    
    func failedNoAnswerLabel(label: UILabel) {
        
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        label.text = self.text
        label.textAlignment = .center
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
        label.addDashedBorder(boarderColor: .red)
    }
    
    func noAnswerLabel(label: UILabel) {
        
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        label.text = self.text
        label.textAlignment = .center
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
        label.tag = 100
        label.addDashedBorder()
    }
    
    func answerLabel(label: UILabel) {
        
        label.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.textColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        label.text = self.text
        label.textAlignment = .center
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
    }
    
    func defaultSetting(label: UILabel) {
        label.backgroundColor = #colorLiteral(red: 0.1654851139, green: 0.6282587051, blue: 0.831725657, alpha: 1)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = self.text
        label.textAlignment = .center
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if sortWord.isAlreadyAnswer && !sortWord.isAnswerFlg {
            return
        }
        
        guard sortWord.text != "   " else {
            return
        }
        
        sortWord.isCorrectAnswer = false
        
        if let touchEvent = touches.first  {
            
            if let view = touchEvent.view, let _ = view as? DragableLabel {
                // dump(label)
                
                
                if let _ = dragLabel {
                    dragLabel.removeFromSuperview()
                    dragLabel = nil
                }
                
                dragLabel = UILabel(frame: self.frame)
                if sortWord.isAnswerFlg {
                    answerLabel(label: dragLabel)
                    
                } else {
                    defaultSetting(label: dragLabel)
                }
                location = dragLabel.frame.origin
                self.superview?.addSubview(dragLabel)
                self.alpha = 0.3
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        // print("touchesMoved")
        
        guard let _ = dragLabel else {
            return
        }
        
    
        if let touchEvent = touches.first  {
            
            // ドラッグ前の座標
            let preDx = touchEvent.previousLocation(in: superview).x
            let preDy = touchEvent.previousLocation(in: superview).y
            
            // ドラッグ後の座標
            let newDx = touchEvent.location(in: superview).x
            let newDy = touchEvent.location(in: superview).y
            
            // ドラッグしたx座標の移動距離
            let dx = newDx - preDx
            
            // ドラッグしたy座標の移動距離
            let dy = newDy - preDy
            
            // 画像のフレーム
            var viewFrame: CGRect = dragLabel.frame
            
            // 移動分を反映させる
            viewFrame.origin.x += dx
            viewFrame.origin.y += dy
            dragLabel.frame = viewFrame
            
            // delegate?.labelMoveing(label: dragLabel, position: touchEvent.location(in: superview))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.touchesEnded(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let _ = dragLabel else {
            return
        }
        
        if let touchEvent = touches.first  {
            
            // ドラッグ後の座標
            let position = touchEvent.location(in: superview)
            
            if let superV = superview {
                
                for view in superV.subviews {
                    if let label1 = view as? DragableLabel {
                        
                        guard label1.sortWord.isAnswerFlg else {
                            
                            self.removeDragLabel()
                            return
                        }
                        
                        if label1.frame.contains(position) {
                            
                            // let tmp = self
                            
                            
                            delegate?.labelMoveEnded(sortWord: self.sortWord, changedLabel: label1)
                            
                            removeDragLabel(isAnimation: false)
                            return
                        }
                    }
                }
            }
        }
        
        removeDragLabel()
    }
    
    func removeDragLabel(isAnimation: Bool = true) {
        
        if isAnimation {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.dragLabel.frame.origin = self.location
            }) { (finished) in
                self.dragLabel.removeFromSuperview()
                self.dragLabel = nil
                self.alpha = 1.0
            }
            
        } else {
            
            self.dragLabel.removeFromSuperview()
            self.dragLabel = nil
        }
    }
}


// MARK: - Class SortWord

class SortWord {
    
    var text: String!
    var index: Int = 0
    var isCorrectAnswer = true
    
    //
    var isAnswerFlg: Bool = false
    var isAlreadyAnswer: Bool = false
    
    init(text: String) {
        self.text = text
    }
    
    func copy() -> SortWord {
        let sortWord = SortWord(text: self.text)
        sortWord.index = self.index
        sortWord.isAnswerFlg = self.isAnswerFlg
        sortWord.isAlreadyAnswer = self.isAlreadyAnswer
        return sortWord
    }
}


// MARK: - extension

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

extension UIView {
    
    func addDashedBorder(boarderColor: UIColor = .black) {
        let color = boarderColor.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [5 ,2]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}


