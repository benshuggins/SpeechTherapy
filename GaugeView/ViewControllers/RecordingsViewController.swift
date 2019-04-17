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
import CoreData

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

@IBDesignable
class RecordingsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var recordTableView: UITableView!
    
    // Core Data MOC variables
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Countdown timer variables
    var countDownTimer = Timer()
    var seconds = 15   // countdown seconds
    var isTimerRunning = false
    
    var scoreAnswer: String = "" // pass fail
    var STT: String = ""
    var roundedAvgDB: Double = 0
    var numberOfRecords: Double = 0
    
    
    //SOT
    var recordings: [Recordings] = []
    
    // SOT for core data 
    var entries: [Entry] = []
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    //MARK: - Speech to Text
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    var lang: String = "en-US"
    
    //MARK: - Text to Speech outlets
    
    @IBOutlet weak var StartStopButton: UIButton!
    @IBOutlet weak var textViewST: UITextView!
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    
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
        test.backgroundColor = .gray
        
        self.view.backgroundColor = .white
        //MARK: - TextToSpeech segment control
        
        StartStopButton.isEnabled = false  //2
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate  //3
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.StartStopButton.isEnabled = isButtonEnabled
            }
        }
        
        
        //MARK: - AVAudioSession
        
        recordingSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
        test.backgroundColor = .clear
        view.addSubview(test)
    }
    
    //MARK: - CORE DATA - MOC FETCH
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            entries = try context.fetch(Entry.fetchRequest()) // SOT core data
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        print(context.registeredObjects.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordTableView.reloadData()
    }
    
    //MARK: - countdown timer
    func runTimer() {
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    
    //MARK: -😍 Score and countDownTimer
    
    @objc func updateTimer() {
        if seconds < 1 {
            stopGauge()
            
            
            let passFailMessage = ScoreController.sharedInstance.calculateScore()
            countDownTimer.invalidate()
            self.view.showToast(toastMessage: passFailMessage, duration: 7.0)
            
            scoreAnswer = passFailMessage
            //    print("😕😕😕😕😕😕😕😕😕😕😕")
            
            // Im getting back both of theses I just need to add my score to the corresponding cell
            let record = self.recordings.last
            
            record?.score = scoreAnswer
            print(record?.score as Any)
            recordTableView.reloadData()
            
        } else {
            seconds -= 1
            timerLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    //MARK: - Time Converter
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //MARK: - Text to Speech Actions
    @IBAction func segmentControlTapped(_ sender: Any) {
        switch segmentCtrl.selectedSegmentIndex {
        case 0:
            lang = "en-US"
            break;
        case 1:
            lang = "fr-FR"
            break;
        case 2:
            lang = "de-DE"
            break;
        case 3:
            lang = "es-ES"
            break;
        case 4:
            lang = "it-IT"
            break;
        default:
            lang = "en-US"
            break;
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
    }
    //MARK: - AVAUDIOSESSION - Set up .setCategory record
    
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setCategory(.record, mode: .default, options: [])
            //try audioSession.setCategory(AVAudioSession.Category.record)           //<=========== Problematic
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                //MARK: - STT spit out from library
                
                self.STT = (result?.bestTranscription.formattedString)!
                
                print("😛😛😛😛😛😛😛😛😛😛😛😛😛😛😛😛😛😛😛😛")
                
                // get the last record from the model and attach it
                
                //>   let record = self.recordings.last
                
                //attach record to sst to the last record but they come off in a set of strings
                //>    record?.sst = self.STT
                
                
                //trying to add to the same record
                
                
                // set the textview that display the speech to text
                self.textViewST.text = self.STT
                
                
                isFinal = (result?.isFinal)!
                // print out tet from tet to speach SPIT OUT POINT
                
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.StartStopButton.isEnabled = true
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textViewST.text = "Press record and say a phrase to test your volume matching skills!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            StartStopButton.isEnabled = true
        } else {
            StartStopButton.isEnabled = false
        }
    }
    
    
    //MARK: - Stop The Gauge Button
    @IBAction func stopGaugeButtonTapped(_ sender: Any) {
        stopGauge()
        
    }
    
    //MARK: - stop the gauge
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
    //MARK: - STT action intitiates
    
    @IBAction func TTSTapped(_ sender: Any) {
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            StartStopButton.isEnabled = false
            // StartStopButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            // StartStopButton.setTitle("Stop Recording", for: .normal)
        }
        
    }
    
    //MARK: - RECORDING START SETUP THE SESSION - RECORDING INDIVIDUAL RECORDS
    @IBAction func recordButtonTapped(_ sender: Any) {
        
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
                
                
                //MARK: - AVERAGE POWER FOR CHANNEL
                let dB = audioRecorder.averagePower(forChannel: 0)
                //let result = pow(10.0, db / 20.0) * 120.0
                
                decibels1 = Float(Double(round(10 * Double(dB+100))/10))
                //  print(decibels1)
                buttonLabel.setTitle("Stop", for: .normal)
                
            } catch {
                
                displayAlert(title: "Problem!" , message: "Recording failed")
                
            }
        } else {
            
            audioRecorder.stop()
            
            
            //MARK: - 😫 RECORD MODEL ADD TO
            print("😫😫😫😫😫😫😫😫😫😫😫😫😫")
            
            // saving to regular Model
            let record = Recordings(recordings: numberOfRecords, decibels: (decibels1), sst: self.textViewST.text, score: scoreAnswer)
            
            // let record = Recordings()
            
            // saving to Core data model
            let entry = Entry(entity: Entry.entity(), insertInto: context)
            
            entry.score = record.score
            entry.recordings = record.recordings
            entry.decibels = record.decibels
            entry.sst = record.sst
            appDelegate.saveContext()
            
            entries.append(entry)
            
            
            //            @IBAction func addFriend() {
            //                let data = FriendData()   // isntantiate new FriendData() isntance so that you don't edit an exsiting entry
            //                let friend = Friend(entity: Friend.entity(), insertInto: context)
            //                friend.name = data.name
            //                friend.address = data.address  //<< adding a new entry // connecting model to the entity CD
            //                appDelegate.saveContext()
            //                friends.append(friend)
            //                let index = IndexPath(row:friends.count - 1, section:0)
            //                collectionView?.insertItems(at: [index])
            //            }
            //
            
            
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
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as? RecordingsTableViewCell
        cell?.delegate = self
        
        
        let record = entries[indexPath.row] //<< changed Sot to coredata SOT
        
        cell?.recordingsLandingPad = record
        
        return cell ?? UITableViewCell()
    }
    
    
    //MARK: - ERROR ALERT
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    //MARK: - START AUDIOSESSION
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
    //MARK: - DOCUMENTS DIRECTORY GET SAVED FILES INDIVIDUAL RECORDINGS
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
    //MARK: - TIMER CALL AVERAGE PWR CHANNEL
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
    
    //MARK: - TAKE AVG ARRAY SMOOTH OUT GAUGE FLUCTUATIONS 
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








