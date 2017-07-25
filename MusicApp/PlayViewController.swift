//
//  PlayViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 6/28/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

var didChooseFromPlayList = "didChooseFromPlayList"

class PlayViewController: UIViewController, AVAudioPlayerDelegate {
    
    var playQueue: PlayListViewController!

    @IBOutlet weak var playingNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shufferButton: UIButton!
    
    @IBOutlet weak var artworkImage: UIImageView!
    
    @IBOutlet weak var playProgress: UISlider!
    
    var audioLength = 0.0
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (Shared.shared.currentPlaying == nil){
            playingNameLabel.text = "No Song"
            artistNameLabel.text = "No Artist"
            durationLabel.text = "00:00"
        }
        else{
        prepare()
        Shared.shared.audioPlayer.delegate = self
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayDisplay(_:)), name: NSNotification.Name(rawValue: didChooseFromPlayList), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func prepare(){
        audioLength = Shared.shared.audioPlayer.duration
        playProgress.maximumValue = CFloat(Shared.shared.audioPlayer.duration)
        playProgress.minimumValue = 0.0
        playProgress.value = Float(Shared.shared.audioPlayer.currentTime)
        let time = calculateTimeFromNSTimeInterval(Shared.shared.audioPlayer.currentTime)
        durationLabel.text  = "\(time.minute):\(time.second)"
        
        playingNameLabel.text = Shared.shared.currentPlaying?.title
        artistNameLabel.text = Shared.shared.currentPlaying?.artist
       
        startTimer()
        if (Shared.shared.currentPlaying?.artWork == nil){
            artworkImage.image = UIImage(named: "default")
        }
        else{
            artworkImage.image = UIImage(data: (Shared.shared.currentPlaying?.artWork)!)
        }
        if Shared.shared.audioPlayer.isPlaying == true{
            playButton.setTitle("Pause", for: .normal)
        }
        if Shared.shared.reapeatValue == true{
            repeatButton.isSelected = true
        }
        if Shared.shared.shufferValue == true{
            shufferButton.isSelected = true
        }
    }
    
    func updatePlayDisplay(_ notification: Notification){
        audioLength = Shared.shared.audioPlayer.duration
        playProgress.maximumValue = CFloat(Shared.shared.audioPlayer.duration)
        playProgress.minimumValue = 0.0
        
        playingNameLabel.text = Shared.shared.currentPlaying?.title
        artistNameLabel.text = Shared.shared.currentPlaying?.artist

        Shared.shared.audioPlayer.delegate = self
        Shared.shared.playSong()
        playButton.setTitle("Pause", for: .normal)
        startTimer()
        
        if (Shared.shared.currentPlaying?.artWork == nil){
            artworkImage.image = UIImage(named: "default")
        }
        else{
            artworkImage.image = UIImage(data: (Shared.shared.currentPlaying?.artWork)!)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)

 
    }
    
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayViewController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func update(_ timer: Timer){
        if !Shared.shared.audioPlayer.isPlaying{
            return
        }
        let time = calculateTimeFromNSTimeInterval(Shared.shared.audioPlayer.currentTime)
        durationLabel.text  = "\(time.minute):\(time.second)"
        playProgress.value = CFloat(Shared.shared.audioPlayer.currentTime)
        UserDefaults.standard.set(playProgress.value , forKey: "playerProgressSliderValue")
    }
    
    //Return Song Length
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    func showTotalSongLength(){
        calculateSongLength()
        //totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        //        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }

    // MARK:- AVAudioPlayer Delegate's Callback method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            if Shared.shared.reapeatValue == true {
                Shared.shared.playSong()
            }
            if Shared.shared.shufferValue == true {
                let shufferIndex = Int(arc4random_uniform(UInt32(Shared.shared.playList.count)))
                Shared.shared.currentPlaying = Shared.shared.playList[shufferIndex]
                do{
                    let audioPath = Bundle.main.path(forResource: Shared.shared.currentPlaying?.title, ofType: "mp3")
                    try Shared.shared.audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
                }
                catch{
                    print("ERROR")
                }
                prepare()
                Shared.shared.audioPlayer.delegate = self
                Shared.shared.playSong()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
            }
            if (Shared.shared.reapeatValue == false) && (Shared.shared.shufferValue == false){
                playButton.setTitle("Play", for: .normal)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdatePlayDone), object: nil)
            }
        }
    }
    

    @IBAction func play(_ sender: Any) {
        if Shared.shared.audioPlayer.isPlaying == true{
            Shared.shared.audioPlayer.pause()
            playButton.setTitle("Play", for: .normal)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdatePauseToMain), object: nil)
        }
        else{
            Shared.shared.playSong()
            playButton.setTitle("Pause", for: .normal)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdatePauseToMain), object: nil)
        }

    }
    
    
    @IBAction func changePlayTime(_ sender: UISlider) {
         Shared.shared.audioPlayer.currentTime = TimeInterval(sender.value)
    }
    @IBAction func repeatClick(_ sender: Any) {
       if Shared.shared.reapeatValue == true
       {
         Shared.shared.reapeatValue = false
         repeatButton.isSelected = false
        }
        else{
         Shared.shared.reapeatValue = true
         repeatButton.isSelected = true
         if (Shared.shared.shufferValue == true){
            Shared.shared.shufferValue = false
            shufferButton.isSelected = false
        }
        }
    }
    
    @IBAction func shufferClick(_ sender: Any) {
        if Shared.shared.shufferValue == true{
            Shared.shared.shufferValue = false
            shufferButton.isSelected = false
        }
        else{
            Shared.shared.shufferValue = true
            shufferButton.isSelected = true
            if (Shared.shared.reapeatValue == true){
                Shared.shared.reapeatValue = false
                repeatButton.isSelected = false
            }
        }
    }
    @IBAction func nextClick(_ sender: Any) {
        var currentIndex = 0
        for i in 0 ..< Shared.shared.playList.count{
            if Shared.shared.currentPlaying?.title == Shared.shared.playList[i].title{
                currentIndex = i
            }
        }
        if ((currentIndex + 1) >= Shared.shared.playList.count){
            Shared.shared.currentPlaying = Shared.shared.playList[0]
        }
        else{
        Shared.shared.currentPlaying = Shared.shared.playList[currentIndex + 1]
        }
        do{
            let audioPath = Bundle.main.path(forResource: Shared.shared.currentPlaying?.title, ofType: "mp3")
            try Shared.shared.audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch{
            print("ERROR")
        }
        prepare()
        Shared.shared.audioPlayer.delegate = self
        Shared.shared.playSong()
        playButton.setTitle("Pause", for: .normal)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
    }
    @IBAction func prevClick(_ sender: Any) {
        var currentIndex = 0
        for i in 0 ..< Shared.shared.playList.count{
            if Shared.shared.currentPlaying?.title == Shared.shared.playList[i].title{
                currentIndex = i
            }
        }
        if ((currentIndex - 1) < 0){
            Shared.shared.currentPlaying = Shared.shared.playList[Shared.shared.playList.count - 1]
        }
        else{
            Shared.shared.currentPlaying = Shared.shared.playList[currentIndex - 1]
        }
        do{
            let audioPath = Bundle.main.path(forResource: Shared.shared.currentPlaying?.title, ofType: "mp3")
            try Shared.shared.audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch{
            print("ERROR")
        }
        prepare()
        Shared.shared.audioPlayer.delegate = self
        Shared.shared.playSong()
        playButton.setTitle("Pause", for: .normal)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
        
    }
    
    @IBAction func cancelToPlayViewController(segue:UIStoryboardSegue) {
    }
}



    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

