//
//  GameVC.swift
//  Multiply
//
//  Created by Neil Sood on 12/10/19.
//  Copyright © 2019 Neil Sood. All rights reserved.
//

import UIKit

protocol GameVCDelegate: class {
    func saveScore(score: Int)
}

class GameVC: UIViewController {

// MARK: outlets
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var pointsCounterLabel: UILabel!
    @IBOutlet weak var firstNumLabel: UILabel!
    @IBOutlet weak var secondNumLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var timerProgressView: UIProgressView!
    
// MARK: variables
    var timer = Timer()
    var timerIsOn = false
    var timeRemaining = 1.0
    
    var maxQuestions = 10
    var questionNumber = 1
    var pointsCount = 0
    var firstNum = -1
    var secondNum = -1
    
    var delegate: GameVCDelegate?
    
// MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        print("let's play a game!")
        
        // swipe gesture recognizer setup
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        // bring up num keyboard on load
        answerTextField.becomeFirstResponder()
        answerTextField.keyboardType = .numberPad
        // add listener to track textfield change
        answerTextField.addTarget(self, action: #selector(GameVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // progress timer initializer
        timerProgressView.layer.cornerRadius = 10
        timerProgressView.clipsToBounds = true
//        timerProgressView.layer.sublayers![1].cornerRadius = 10
//        timerProgressView.subviews[1].clipsToBounds = true
        // flip progress bar for countdown
//        timerProgressView.transform = CGAffineTransform(rotationAngle: deg2rad(180.0));
        questionNumber = 1
        resetTimer()
    }
    
    
// MARK: functions
    
    // swipe gesture recognizer handler
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == .down {
            print("Swipe Down")
            timer.invalidate()
            dismiss(animated: true, completion: nil)
        }
    }
    
    // check for correct answer on type
    @objc func textFieldDidChange(_ textField: UITextField) {
        let num = Int(answerTextField.text ?? "0")
        if num == firstNum * secondNum {
            // reset timer after delay to allow answer entry to be fully visible
            perform(#selector(resetTimer), with: nil, afterDelay: 0.2)
        }
    }
    
    // update progress view with timer countdown
    @objc func updateProgressView(){
        
        // change progress increment along with time interval in scheduled timer to adjust speed
        timerProgressView.progress += 0.1
        timerProgressView.setProgress(timerProgressView.progress, animated: true)
        if timerProgressView.progress == 1.0
        {
            // reset timer after delay to allow progress bar to visibly go to the end
            perform(#selector(resetTimer), with: nil, afterDelay: 0.2)
        }
    }
    
    @objc func resetTimer() {
        if questionNumber > maxQuestions { // done with this set of questions
            print(pointsCount)
            delegate?.saveScore(score: pointsCount)
            timer.invalidate()
            dismiss(animated: true, completion: nil)
        }
        else { // go to next question
            updateLabels()
            updateScore(progress: timerProgressView.progress)
            
            questionNumber += 1
            
            timer.invalidate()
            timerProgressView.progress = 0.0
            // change progress increment along with time interval in scheduled timer to adjust speed
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameVC.updateProgressView), userInfo: nil, repeats: true)
            timerIsOn = true
        }
    }
    
    func updateLabels() {
        firstNum = Int.random(in: 1 ... 10)
        secondNum = Int.random(in: 1 ... 10)
        
        firstNumLabel.text = String(firstNum)
        secondNumLabel.text = String(secondNum)
        
        pointsCounterLabel.text = String(pointsCount)
        questionNumberLabel.text = String(questionNumber) + "/10"
        
        answerTextField.text = ""
    }
    
    func updateScore(progress: Float) {
        let multiplier = 1.0 - progress
        pointsCount += Int(multiplier * 1021)
    }
    
    // convert degrees to radians for progress bar inversion
//    func deg2rad(_ number: CGFloat) -> CGFloat {
//        return number * .pi / 180
//    }
}
