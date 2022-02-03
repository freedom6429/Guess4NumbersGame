//
//  ViewController.swift
//  Guess4NumbersGame
//
//  Created by Wen Luo on 2022/1/21.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //先建立好全域變數：answer、userInputs、timesOfTry
    var answer = [String]()
    var userInputs = [String]()
    var timesOfTry = 0
    var isPlaying = true
    
    @IBOutlet var inputTextFields: [UITextField]!
    
    @IBOutlet weak var guessButton: UIButton!
    
    @IBOutlet var recordLabels: [UILabel]!
    
    @IBOutlet weak var resultMessageLabel: UILabel!

    @IBOutlet weak var newGameButton: UIButton!
    
    //產生新的答案
    func generateAnswer() {
        answer = []
        var numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        numbers.shuffle()
        for _ in 1...4 {
            if let number = numbers.popLast() {
                answer.append(String(number))
            }
        }
    }

    //檢查猜的數字生成record struct物件
    func check(userGuess: [String], answer: [String]) -> GuessingRecord {
        var record = GuessingRecord(numberGuessed: userInputs, countOfBMatch: 0, countOfAMatch: 0)
        var numberForBMatchCheck = [String]()
        //先檢查A再檢查B
        //A檢查
        for i in 0...3 {
            if userInputs[i] == answer[i] {
                record.countOfAMatch += 1
            } else {
                numberForBMatchCheck.append(answer[i])
            }
        }
        //B檢查
        for num in numberForBMatchCheck {
            if userInputs.contains(num) {
                record.countOfBMatch += 1
            }
        }
        //回傳結果
        return record
    }
    
    //漸層背景
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            CGColor(srgbRed: 51/255, green: 8/255, blue: 103/255, alpha: 1),
            CGColor(srgbRed: 48/255, green: 207/255, blue: 208/255, alpha: 1)
            
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //textField加上底線
    func setTextFieldBorderBottom(_ textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(3.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: width)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    //Show attributed result
    func showResult(trial: Int, input: String, aMatch: Int, bMatch: Int ){
        let text = NSMutableAttributedString(string: "\(input) \(aMatch)A\(bMatch)B")
        let countRange = NSRange(location: 5, length: 4)
        text.addAttributes([NSMutableAttributedString.Key.foregroundColor: UIColor.red], range: countRange)
        recordLabels[trial].attributedText = NSAttributedString(attributedString: text)
        recordLabels[trial].isHidden = false
    }
    
    //收鍵盤
    @objc func closeNumberPad() {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //設定漸層背景
        setGradientBackground()
        //生成答案
        generateAnswer()
        //將所有text設底線
        for textField in inputTextFields {
            setTextFieldBorderBottom(textField)
        }
        //新增view的tapRecognizer
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(self.closeNumberPad))
        self.view.addGestureRecognizer(tapRecognizer)

     }
    
    //一個TextField只能輸入一個數字，輸入一個字元後馬上跳到下一格，刪除時也是跳回前一格，但可以跳著編輯
    @IBAction func inputNumberTextField(_ sender: UITextField) {
        //先取得目前編輯的textField的index
        let index = inputTextFields.firstIndex(of: sender)!
        //如果目前textField的text長度經過編輯後大於1就要將多的數字丟給下一個textField並成為firstResponder
        if sender.text!.count > 1 {
            //只有前三個會將多的數字丟給下一個textField，最後一個不用，不過全部都要把多的數字去掉
            if index < 3 {
                let newNum = String(sender.text!.suffix(1))
                inputTextFields[index + 1].text = newNum
                inputTextFields[index + 1].becomeFirstResponder()
            }
            sender.text!.remove(at: sender.text!.index(before: sender.text!.endIndex))
        //textField的text經過編輯後長度為0游標會往前面移
        } else if sender.text!.count == 0 {
            //如果是第一個textField就不用把游標往前推
            if index > 0 {
                inputTextFields[index - 1].becomeFirstResponder()
            }
        } else if sender.text!.count == 1 {
            userInputs.append(sender.text!)
        }
    }
    
    @IBAction func submitNumbersButton(_ sender: UIButton) {
        //清空userInputs
        userInputs.removeAll()
        //依照目前輸入的內容更新userInputs，如果判斷包含""表示沒有輸入完整就沒有辦法繼續檢查結果
        for textField in inputTextFields {
            userInputs.append(textField.text!)
        }
        if userInputs.contains("") {
            return
        }
        //若輸入完整就會收鍵盤並開始檢查結果
        view.endEditing(true)
        //將userInputs轉為完整的字串，然後以check函式檢查結果生成record instance儲存到result裡
        var inputString = ""
        for number in userInputs {
            inputString.append(contentsOf: number)
        }
        let result = check(userGuess: userInputs, answer: answer)
        //print到console中供快速測試遊戲
        print("Inputs by user：\(userInputs)")
        print("Answer: \(answer)")
        //將猜測次數和結果資料利用showResult顯示在介面上
        showResult(trial: timesOfTry, input: inputString, aMatch: result.countOfAMatch, bMatch: result.countOfBMatch)
        //猜測結束後次數要加1次與判斷遊戲是否結束並進行對應的介面處理
        timesOfTry += 1
        if (result.countOfAMatch != 4) && (timesOfTry < 10) {
            //沒有猜對時10次以下沒有猜對都可以再猜
            //每次猜完繼續猜時textField都會清空並且回到第一個textField
            for textField in inputTextFields {
                textField.text = ""
            inputTextFields[0].becomeFirstResponder()
            }
        } else {
            //其他情況為遊戲結束，根據是猜中答案或者用完次數來更新介面
            isPlaying = false
            var message = ""
            if result.countOfAMatch == 4 {
                message = "You did a great job!"
            } else if timesOfTry == 10 {
                message = "Oops, you ran out 10 chances..."
            }
            for textField in inputTextFields {
                textField.isEnabled = false
            }
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Rockwell", size: 26.0)]
            resultMessageLabel.attributedText = NSAttributedString(string: message, attributes: attributes as [NSAttributedString.Key : Any])
            resultMessageLabel.isHidden = false
            newGameButton.isHidden = false
            newGameButton.isEnabled = true
        }
    }
    
    
    @IBAction func anotherGameButton(_ sender: UIButton) {
        //textField會全部清空並可以編輯
        for textField in inputTextFields {
            textField.isEnabled = true
            textField.text = ""
        }
        //游標跳會第一個textField，所有record都隱藏起來
        inputTextFields[0].becomeFirstResponder()
        for label in recordLabels {
            label.isHidden = true
        }
        //隱藏結果訊息和Try again按鈕
        resultMessageLabel.isHidden = true
        newGameButton.isHidden = true
        newGameButton.isEnabled = false
        //重置答案和猜測數
        generateAnswer()
        timesOfTry = 0
    }
    
}

