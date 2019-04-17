//
//  Recordings.swift
//  GaugeView
//
//  Created by Ben Huggins on 4/6/19.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class Recordings {
    
    var recordings: Double  //filename
    var decibels: Float  // filename dB
    //weak var score: Score? // pass/ fail
    var sst: String
    var score: String
    
    init(recordings: Double, decibels: Float, sst: String, score: String){
    self.recordings = recordings
    self.decibels = decibels
    self.sst = sst
    self.score = score
   
}
}
