//
//  ViewController.swift
//  GaugeView
//
//  Created by Ben Huggins on 4/1/19.
//  Copyright © 2019 User. All rights reserved.
//

import AVFoundation
import MessageUI
import AVKit
import UIKit
import Speech

//####################################################################################################

@IBDesignable
class RecordingsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var recordTableView: UITableView!
    
    //MARK: - Countdown timer variables
    var countDownTimer = Timer()
    var seconds = 15   // countdown seconds
    var isTimerRunning = false
    
    var roundedAvgDB: Double = 0
    var numberOfRecords: Int = 0
    var recordings: [Recordings] = []
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    //MARK: - Decibel Labels
//    @IBOutlet weak var dBLabel: UILabel!
//    @IBOutlet weak var normLabel: UILabel!
//    @IBOutlet weak var avgLabel: UILabel!
    
    //MARK: - AV Setup
    
    var dBArray: [Double] = []
    var decibels: Float = 0
    var decibels1: Float = 0
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var recordingSession: AVAudioSession!
    
    //var result: Int = 0
    
    var fileName = "audio_file.m4a"
    
    var levelTimer = Timer()
    
    static let sharedInstance = RecordingsViewController()
    
    @IBInspectable
    let test = GaugeView(frame: CGRect(x: 35, y: 44, width: 350, height: 350))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
        test.backgroundColor = .clear
        view.addSubview(test)
    }
    
    //MARK: - countdown timer
    func runTimer() {
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    
    //MARK: -  THIS IS THE END OF THE COUNTDOWN //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    @objc func updateTimer() {
        if seconds < 1 {
            stopGauge()
            let passFailMessage = ScoreController.sharedInstance.calculateScore()
            countDownTimer.invalidate()
            self.view.showToast(toastMessage: passFailMessage, duration: 7.0)
     
        } else {
            seconds -= 1
            timerLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //MARK: - stop the gauge
    @IBAction func stopGaugeButtonTapped(_ sender: Any) {
        stopGauge()
        
    }
    func stopGauge() {
        print("gauge Stopped")
        countDownTimer.invalidate()
        seconds = 15
        timerLabel.text = timeString(time: TimeInterval(seconds))
        levelTimer.invalidate()
        isTimerRunning = false
        
        //MARK: - UPDATE THE GAUGE
        self.test.segmentTapped(segmentPosition: 0.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.0) {
                self.test.value = Double(0.0)
                self.test.segmentTapped(segmentPosition: 0.0)
                self.levelTimer.invalidate()
                
            }
        }
    }
    //MARK: - create a new recording and create a new fileName
    @IBAction func recordButtonTapped(_ sender: Any) {
        //self.view.showToast(toastMessage: "Speak phrase to Record then press Stop", duration: 3.0)
        // print("record Button was tapped")
        if audioRecorder == nil {
            
            // create a new fileName each time record is tapped
            numberOfRecords += 1
            
            let fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                            //AVEncoderBitRateKey : 320000,
                AVNumberOfChannelsKey : 1,
                AVSampleRateKey : 12000 ]
            
            do
            {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                audioRecorder.updateMeters()
            
                
                //MARK: - measure decibel level of recording input sound
                let dB = audioRecorder.averagePower(forChannel: 0)
                //let result = pow(10.0, db / 20.0) * 120.0
                
                decibels1 = Float(Double(round(10 * Double(dB+100))/10))
                
                print(decibels1)
                buttonLabel.setTitle("Stop", for: .normal)
                
            } catch {
                
                displayAlert(title: "Problem!" , message: "Recording failed")
                
            }
        } else {
            // stop the recording
            audioRecorder.stop()
            let record = Recordings(recordings: numberOfRecords, decibels: (decibels1))
            
            recordings.append(record)
            recordTableView.reloadData()
            audioRecorder = nil
            buttonLabel.setTitle("Record", for: .normal)
            
        }
    }
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.recordings.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as? RecordingsTableViewCell
        cell?.delegate = self
        let record = recordings[indexPath.row]
        
        //mark landingPad for cell
        cell?.recordingsLandingPad = record
        
        return cell ?? UITableViewCell()
    }
    
    
    //MARK: - Displays this to user if there is an error
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    //MARK: - used for measuring dB level for gauge
    func startAudioSession(){
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            
            //try recordingSession.setCategory(AVAudioSession.Category.playAndRecord) // problematic ! // here is our metering category
            //try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            //try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            //try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, with: [.duckOthers, .defaultToSpeaker])
            
            
            try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.setupRecorder()
                    } else {
                        print("failed to record")
                    }
                }
            }
        } catch {
            print("failed to record")
        }
    }
    
    func setupRecorder(){
        let recordSettings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              //AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 1,
            AVSampleRateKey : 12000 ]     //44100.0 ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: getFileURL(), settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            //playBtn.isEnabled = false
            
            //MARK: - call the timer function Every 0.10 measure dB
            
            levelTimer = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
            
        }
        catch {
            print("\(error)")
        }
        
    }
    // this is for input recording individual recordings tableView
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getCacheDirectory() -> URL {
        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return docsurl
    }
    
    func getFileURL() -> URL{
        let path  = getCacheDirectory()
        let filePath = path.appendingPathComponent("\(fileName)")
        return filePath
    }
    
    @objc func levelTimerCallback() {
        //print("record Button tapped")
        
        // if sender.currentTitle.text == "Record"{
        audioRecorder.record()
        audioRecorder.updateMeters()
        //1 Straight from apple
        let decibels = audioRecorder.averagePower(forChannel: 0)
        
        //2 average Power for Channel
        // let normalizedValue = pow(10, audioRecorder.averagePower(forChannel: 0) / 20)
        
        // let db = audioRecorder.peakPower(forChannel: 0)
        //let result = pow(10.0, db / 20.0) * 120.0
        
        //let linear = pow (10, decibels / 20)
        
        //MARK: - Checking Testing
        
        //        dBLabel.text = "\(result)"
        //        normLabel.text = "\(normalizedValue)"
        //        avgLabel.text = "\(decibels)"
        
        let roundedResult = Double(round(10 * Double(decibels+85))/10)
        
        takeAvgDBArray(result: roundedResult)
        
    }
    
    // Make a take score button that is pressed "start" and compares how long average
    
    //MARK: - function for preventing fluctuations in gauge
    func takeAvgDBArray(result: Double) {
        
        //        //print("🤨🤨🤨🤨🤨🤨🤨🤨🤨🤨")
        //        print(result)
        dBArray.append(result)
        
        if dBArray.count == 50 {
            
            
            // delay timer to start while gauge calibrates
            //            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            //
            //                self.runTimer()
            //            }
            
            //runTimer()
            let sumdBArray = dBArray.reduce(0, +)
            let avgDB = sumdBArray/50
            dBArray.removeFirst(1)
            
            roundedAvgDB = Double(round(10 * Double(avgDB))/10)
            
            
            ScoreController.sharedInstance.currentGaugeValue(gauge: Float(roundedAvgDB))  //<======================================== Passing current Gauge value to ScoreCpntroller
            
            //MARK: - UPDATE THE GAUGE
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.10) {
                    self.test.value = Double(self.roundedAvgDB)
                    
                }
            }
        }
    }
}
// send volume level from slider back to VC
extension RecordingsViewController: RecordingsTableViewCellDelegate {
    
    func sliderChangeMoved(_ sender: RecordingsTableViewCell, _ slider: UISlider) {
        // print("😂😂😂😂\(slider.value)😂😂😂😂")
        audioPlayer.volume = slider.value
    }
    
    // light up segment that corresponds to dB level recorded and allow gauge to start measuring dB
    func startExerciseButtonTapped(_ sender: RecordingsTableViewCell) {
        
        // Inform user
        self.view.showToast(toastMessage: "Calibrating Gauge! Maintain your Volume so Needle points at red segment for the next 15 seconds", duration: 6.0)
        // wait for gauge to calibrate before starting timer
        DispatchQueue.main.asyncAfter(deadline: .now()+6.5) {
            if self.isTimerRunning == false {
                self.runTimer()
            }
        }
        
        //runTimer()
        print("made it to Parent of startEX button")
        guard let segment = sender.recordingsLandingPad else {return}
        let segmentPosition = segment.decibels
        //print("😂😂😂😂\(segmentPosition)😂😂😂😂")
        test.segmentTapped(segmentPosition: segmentPosition)
        
        //MARK: - PASSING SEGMENT AMOUNT
        
        ScoreController.sharedInstance.measureScore(input: segmentPosition)   // <======================================================= Passing dB position to ScoreController
        
        self.startAudioSession()
    }
    
    // pass back filename from cell and play .m4a file
    func playRecordingButtonTapped(_ sender: RecordingsTableViewCell) {
        print("made it to Parent of playRecording button")
        guard let item = sender.recordingsLandingPad else {return}
        let path = getDirectory().appendingPathComponent("\(item.recordings).m4a")
        print("\(item.recordings).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
            
        } catch {
            print("there was an error playing audio")
            
        }
        
    }
}








