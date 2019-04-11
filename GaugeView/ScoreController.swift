//
//  ScoringController.swift
//  GaugeView
//
//  Created by Ben Huggins on 4/10/19.
//  Copyright © 2019 User. All rights reserved.
//


import Foundation

class ScoreController {
    
    var scoreArray: [Float] = []
    var upperBound: Float = 0
    var lowerBound: Float = 0
    
    let recordingController = RecordingController()
    
    static let sharedInstance = ScoreController()
    
    
    func currentGaugeValue(gauge: Float) {
        print("😛😛😛😛\(gauge)")
        scoreArray.append(gauge)
        print("Total score array count: \(scoreArray.count)")
    }
    
    // if 17 = range between 15 - 19
    func measureScore(input: Float) {
        print("😡😡😡😡\(input)")
        
        
        let roundTen = 10 * Int(round(Double(input / 10)))
        print("😕\(roundTen)")
        
        if roundTen < Int(input) {
            lowerBound = Float(roundTen)
            upperBound = Float(roundTen + 10)
        } else if roundTen > Int(input) {
            lowerBound = Float(roundTen - 10)
            upperBound = Float(roundTen)
            
        }
    }
    func calculateScore() -> String {
        
        // filter the array by the upper and lower bounds
        let correctFilteredArray = self.scoreArray.filter({ Int($0) > Int(self.lowerBound) && Int($0) < Int(self.upperBound) })
        let wrongFilteredArray = self.scoreArray.filter({ Int($0) < Int(self.lowerBound) || Int($0) > Int(self.upperBound) })
        
        
        // get the count of each array
        let filteredCorrect = correctFilteredArray.count
        let filteredWrong = wrongFilteredArray.count
        
        print("Correct Count: \(filteredCorrect)")
        print("Incorrect Count: \(filteredWrong)")
        
        scoreArray = []
        
        //compare the count of each array
        if filteredCorrect > filteredWrong {
            
            //RecordingsViewController.sharedInstance.view.showToast(toastMessage: "You Passed!", duration: 5.0)
            print("You passed")
            return "You passed!"
            
        } else {
            
            // RecordingsViewController.sharedInstance.view.showToast(toastMessage: "You Failed!", duration: 5.0)
            print("you failed")
            return "You Failed!"
        }
    }
}



