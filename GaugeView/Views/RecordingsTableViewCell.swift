//
//  RecordingsTableViewCell.swift
//  GaugeView
//
//  Created by Ben Huggins on 4/6/19.
//  Copyright © 2019 User. All rights reserved.


// add score to the cell
//dfadfawdf

import UIKit

class RecordingsTableViewCell: UITableViewCell {
 
    var updatedValue: Float = 0
    var sliderLevel: Int = 0
    
    var delegate: RecordingsTableViewCellDelegate?
    
    //MARK: - Cell Landing Pad
    var recordingsLandingPad: Entry? {  // < changed to SOT landing pad
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var passFailLabel: UILabel!
    @IBOutlet weak var speechTextLabel: UILabel!
    @IBOutlet weak var playRecordingButtonLabel: UIButton!
    @IBOutlet weak var startExerciseButtonLabel: UIButton!
    
    @IBOutlet weak var recordingNameLabel: UILabel!
    @IBOutlet weak var dBLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   
    }
    
    // change decibel level with the slider, move the slider to where the dB input us set too!!!
    @IBAction func sliderChangeMoved(_ sender: UISlider) {
        guard let record = recordingsLandingPad else {return}
        
       // possibly multiply slider value 0 to 1 so it corresponds to increasing dB value!!
       var sliderValue: Float = 0
        sliderValue = Float(sender.value)
        updatedValue = sliderValue

        // update dB label to increased value
        let sliderLevel = record.decibels + updatedValue

        let roundeddBMeasure = Double(round(10 * Double(sliderLevel))/10)
        dBLabel.text = "\(roundeddBMeasure)"
       
       // print("🧐\(String(describing: volumeSlider))")
       // delegate?.sliderChangeMoved(self, volumeSlider)
    
    }
    
    @IBAction func startExerciseButtonTapped(_ sender: Any) {
    print("startEX Button tapped inside cell")
        delegate?.startExerciseButtonTapped(self)
    }
    
    
    // pass the name of the reording back to VC to be played
    @IBAction func playRecordingButtonTapped(_ sender: Any) {
    print("play Recording Button tapped inside cell")
        delegate?.playRecordingButtonTapped(self)
    
    }
    
    func updateViews() {
        guard let record = recordingsLandingPad else {return}
        recordingNameLabel.text = "Recording: \(record.recordings)"
        
        dBLabel.text = "\(record.decibels + updatedValue) dB"
        
        speechTextLabel.text = record.sst
        passFailLabel.text = record.score
        
    }

}
protocol RecordingsTableViewCellDelegate: class {
    func startExerciseButtonTapped(_ sender: RecordingsTableViewCell)
    func playRecordingButtonTapped(_ sender: RecordingsTableViewCell)
    func sliderChangeMoved(_ sender: RecordingsTableViewCell, _ slider: UISlider)

}


