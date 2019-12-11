//
//  MainVC.swift
//  Multiply
//
//  Created by Neil Sood on 12/10/19.
//  Copyright © 2019 Neil Sood. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController {
    
// MARK: outlets
    @IBOutlet weak var highScoreNumLabel: UILabel!
    @IBOutlet weak var lastScoreNumLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
// MARK: variables
    var data: [Score] = []
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
// MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        print("welcome back mr. sood")
        
        // initialize style for start button
        startButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
        startButton.layer.cornerRadius = 8

    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchScoreItems()
        if data.count == 0 {
            lastScoreNumLabel.text = "0"
            highScoreNumLabel.text = "0"
        }
        else {
            lastScoreNumLabel.text = String(data[data.count-1].lastScore)
            highScoreNumLabel.text = String(data[data.count-1].highScore)
        }
    }
    
    // set delegate to self
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! GameVC
        dest.delegate = self
    }
    
// MARK: actions
    
    // segue to game
    @IBAction func startPressed(_ sender: UIButton) {
        print("let's go!")
        performSegue(withIdentifier: "ShowGameSegue", sender: self)
    }
    
    // clear core data (for testing purposes)
    @IBAction func clearCoreDataPressed(_ sender: UIButton) {
        print("clear core data")
        if data.count == 1 {
            let score = data[0]
            context.delete(score)
            
            do {
                try self.context.save()
            } catch {
                print("\(error)")
            }
            
            data = []
            
            lastScoreNumLabel.text = "0"
            highScoreNumLabel.text = "0"
        }
        
        else {
            print("there is nothing to clear")
        }
        
//        print(data)
        
    }
    
    
    
// MARK: functions
    
    func fetchScoreItems() {
        let request: NSFetchRequest<Score> = Score.fetchRequest()
        
        do {
            data = try context.fetch(request)
        } catch {
            print("\(error)")
        }
        
    }
    
    
}


// MARK: extensions
extension MainVC: GameVCDelegate {
    // update high score if applicable and set last score
    func saveScore(score: Int) {
        print("save score")
        var addScore: Score?
        // prepare to save new entry in CoreData
        if data.count == 0 {
            print("no data")
            addScore = Score(context: context)
        }
        else {
            print("Current data",data[0])
            addScore = data[0]
        }
        
        addScore!.lastScore = Int16(score)
//        lastScoreNumLabel.text = String(score)
        
        let highScore = Int(highScoreNumLabel.text ?? "-1")
        
        if score > highScore ?? -1 {
//            highScoreNumLabel.text = String(score)
            addScore!.highScore = Int16(score)
        }
        else {
            addScore!.highScore = Int16(highScore!)
        }
        
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
        
        
        fetchScoreItems()
        lastScoreNumLabel.text = String(data[0].lastScore)
        highScoreNumLabel.text = String(data[0].highScore)
        
//        print("order",data)
//        print(data.count)
    }
}
