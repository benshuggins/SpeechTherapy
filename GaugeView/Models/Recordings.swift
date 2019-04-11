//
//  Recordings.swift
//  GaugeView
//
//  Created by Ben Huggins on 4/6/19.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class Recordings {
    
    var recordings: Int
    var decibels: Float
    weak var score: Score?
    
    init(recordings: Int, decibels: Float){
    self.recordings = recordings
    self.decibels = decibels
    
}
}
