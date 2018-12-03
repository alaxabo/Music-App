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
        if (Shared.shared.currentPlaying != nil){
        prepare()
        Shared.shared.audioPlayer.delegate = self
        }
        setupNowPlayingInfoCentre()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayDisplay(_:)), name: NSNotification.Name(rawValue: didChooseFromPlayList), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (Shared.shared.currentPlaying == nil){
            playingNameLabel.text = "No Song"
            artistNameLabel.text = "No Artist"
            durationLabel.text = "00:00"
        }
        else{
        if Shared.shared.audioPlayer.isPlaying{
            //playButton.setTitle("Pause", for: .normal)
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
            artworkImage.startRotating()
        }
        }
        if Shared.shared.reapeatValue == true{
            repeatButton.isSelected = true
            repeatButton.backgroundColor = .red
        }
        if Shared.shared.shufferValue == true {
            shufferButton.isSelected = true
            shufferButton.backgroundColor = .red
        }
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
        let time = Shared.shared.calculateTimeFromNSTimeInterval(Shared.shared.audioPlayer.currentTime)
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
    }
    
    @objc func updatePlayDisplay(_ notification: Notification){
        audioLength = Shared.shared.audioPlayer.duration
        playProgress.maximumValue = CFloat(Shared.shared.audioPlayer.duration)
        playProgress.minimumValue = 0.0
        
        playingNameLabel.text = Shared.shared.currentPlaying?.title
        artistNameLabel.text = Shared.shared.currentPlaying?.artist

        Shared.shared.audioPlayer.delegate = self
        Shared.shared.playSong()
        //playButton.setTitle("Pause", for: .normal)
        playButton.setImage(UIImage(named: "Pause"), for: .normal)
        startTimer()
        artworkImage.startRotating()
        
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
    
    @objc func update(_ timer: Timer){
        if !Shared.shared.audioPlayer.isPlaying{
            return
        }
        let time = Shared.shared.calculateTimeFromNSTimeInterval(Shared.shared.audioPlayer.currentTime)
        durationLabel.text  = "\(time.minute):\(time.second)"
        playProgress.value = CFloat(Shared.shared.audioPlayer.currentTime)
        UserDefaults.standard.set(playProgress.value , forKey: "playerProgressSliderValue")
    }
    
    // MARK:- AVAudioPlayer Delegate's Callback method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            if Shared.shared.reapeatValue == true {
                Shared.shared.playSong()
                artworkImage.startRotating()
            }
            if Shared.shared.shufferValue == true {
                Shared.shared.currentPlaying = Shared.shared.playList[Int(arc4random_uniform(UInt32(Shared.shared.playList.count)))]
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
                artworkImage.startRotating()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateToPlayList), object: nil)
            }
            if (Shared.shared.reapeatValue == false) && (Shared.shared.shufferValue == false){
                //playButton.setTitle("Play", for: .normal)
                playButton.setImage(UIImage(named: "Play"), for: .normal)
                artworkImage.stopRotating()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdatePlayDone), object: nil)
            }
        }
    }
    func pause(){
        Shared.shared.pauseSong()
    }
    
    func setupNowPlayingInfoCentre() {
        try! AVAudioSession.sharedInstance().setActive(true)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default)
        } catch {
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        MPRemoteCommandCenter.shared().playCommand.addTarget(handler: {event in
            self.playButton.setImage(UIImage(named: "Pause"), for: .normal)
            self.artworkImage.startRotating()
            return .success
        })
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(handler: {event in
            self.playButton.setImage(UIImage(named: "Play"), for: .normal)
            self.artworkImage.stopRotating()
            return .success
        })

        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(handler: {event in
            Shared.shared.nextSong()
            self.prepare()
            Shared.shared.audioPlayer.delegate = self
            Shared.shared.playSong()
            //playButton.setTitle("Pause", for: .normal)
            self.playButton.setImage(UIImage(named: "Pause"), for: .normal)
            self.artworkImage.startRotating()
            //self.rotateView(targetView: self.artworkImage, duration: 4.0)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateToPlayList), object: nil)
            return .success
        })
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(handler: {event in
            Shared.shared.prevSong()
            self.prepare()
            Shared.shared.audioPlayer.delegate = self
            Shared.shared.playSong()
            //playButton.setTitle("Pause", for: .normal)
            self.playButton.setImage(UIImage(named: "Pause"), for: .normal)
            self.artworkImage.startRotating()
            //self.rotateView(targetView: self.artworkImage, duration: 4.0)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateToPlayList), object: nil)
            return .success
        })
        
    }

    

    @IBAction func play(_ sender: Any) {
        if Shared.shared.currentPlaying == nil{
            playButton.setImage(UIImage(named: "Play"), for: .normal)
        }
        else{
        if Shared.shared.audioPlayer.isPlaying == true{
            Shared.shared.pauseSong()
           // playButton.setTitle("Play", for: .normal)
            playButton.setImage(UIImage(named: "Play"), for: .normal)
            artworkImage.stopRotating()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdatePauseToMain), object: nil)
        }
        else{
            Shared.shared.playSong()
           // playButton.setTitle("Pause", for: .normal)
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
            artworkImage.startRotating()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdatePauseToMain), object: nil)
        }
        }
    }
    
    
    @IBAction func changePlayTime(_ sender: UISlider) {
         Shared.shared.audioPlayer.currentTime = TimeInterval(sender.value)
        Shared.shared.updateInfoMPNowPlaying()
    }
    @IBAction func repeatClick(_ sender: Any) {
       if Shared.shared.reapeatValue == true
       {
         Shared.shared.reapeatValue = false
         //repeatButton.isSelected = false
         repeatButton.backgroundColor = .none
        }
        else{
         Shared.shared.reapeatValue = true
         repeatButton.isSelected = true
         repeatButton.backgroundColor = .red
         if (Shared.shared.shufferValue == true){
            Shared.shared.shufferValue = false
            //shufferButton.isSelected = false
            shufferButton.backgroundColor = .none
        }
        }
    }
    
    @IBAction func shufferClick(_ sender: Any) {
        if Shared.shared.shufferValue == true
        {
            Shared.shared.shufferValue = false
            //shufferButton.isSelected = false
            shufferButton.backgroundColor = .none
        }
        else{
            Shared.shared.shufferValue = true
            shufferButton.isSelected = true
            shufferButton.backgroundColor = .red
            if (Shared.shared.reapeatValue == true){
                Shared.shared.reapeatValue = false
               // repeatButton.isSelected = false
                repeatButton.backgroundColor = .none
            }
        }
    }
    @IBAction func nextClick(_ sender: Any) {
        if (Shared.shared.currentPlaying != nil){
        Shared.shared.nextSong()
        prepare()
        Shared.shared.audioPlayer.delegate = self
        Shared.shared.playSong()
        //playButton.setTitle("Pause", for: .normal)
        playButton.setImage(UIImage(named: "Pause"), for: .normal)
        artworkImage.startRotating()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateToPlayList), object: nil)
        }
    }
    
    @IBAction func prevClick(_ sender: Any) {
        if (Shared.shared.currentPlaying != nil){
        Shared.shared.prevSong()
        prepare()
        Shared.shared.audioPlayer.delegate = self
        Shared.shared.playSong()
        //playButton.setTitle("Pause", for: .normal)
        playButton.setImage(UIImage(named: "Pause"), for: .normal)
        artworkImage.startRotating()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didupdateToPlayList), object: nil)
        }
        
    }
    
    @IBAction func cancelToPlayViewController(segue:UIStoryboardSegue) {
    }
    
}

extension UIView {
    func startRotating(duration: Double = 25) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(M_PI * 2)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
