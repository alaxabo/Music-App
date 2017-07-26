//
//  ViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 6/21/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

var didChooseLeftTab = "didChooseLeftTab"
var didSelectPlayingSong = "didSelectPlayingSong"
var didupdateFromPlayScreen = "didupdateFromPlayScreen"
var didupdatePlayDone = "didupdatePlayDone"
var didupdatePauseToMain = "didupdatePauseToMain"

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var tabButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var playingArtist: UILabel!
    @IBOutlet weak var songTable: UITableView!
    @IBOutlet weak var playingName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playProgress: UISlider!
    @IBOutlet weak var currentArtwork: UIImageView!
    
    
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        return recognizer
    }()
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    
    var categoryType = ["Songs","Albums","Artists"]
    var didSelected = [Bool](repeating: false, count: 3)
    var selectedType: String?
    var currentSong: Song?
    var audioLength = 0.0
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Shared.shared.currentPlaying == nil){
        playingName.text = "No Song"
        playingArtist.text = "No Artist"
        playProgress.value = 0.0
        }
        
        
        self.searchBar.placeholder = "Search ..."
        self.searchBar.tintColor = UIColor.white
        self.searchBar.barTintColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        // Do any additional setup after loading the view, typically from a nib.
        
        //Tab Menu Set
        
        if self.revealViewController() != nil{
            tabButton.target = self.revealViewController()
            tabButton.action = #selector(SWRevealViewController.revealToggle(_:))
            //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 150
        }
        
        //Set Category
        
        if selectedType == nil {
            didSelected[0] = true
            selectedType = categoryType[0]
        }
        else {
            for i in 0...2 {
                if categoryType[i] == selectedType{
                    didSelected[i] = true
                }
            }
        }
        for i in 0...2 {
            if didSelected[i] == true{
                let indexPath = IndexPath(row: i, section: 0)
                collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: true)
            }
        }
        //Move To Play Screen When Tap Artwork
//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
//        recognizer.numberOfTapsRequired = 1
       // currentArtwork.addGestureRecognizer(recognizer)
        //currentArtwork.isUserInteractionEnabled = true
        setupNowPlayingInfoCentre()
        
        //Notification Receive
        NotificationCenter.default.addObserver(self, selector: #selector(getSelectFromLeftTab(_:)), name: NSNotification.Name(rawValue: didChooseLeftTab), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playSelectedSong(_:)), name: NSNotification.Name(rawValue: didSelectPlayingSong), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMainScreen(_:)), name: NSNotification.Name(rawValue: didupdateFromPlayScreen), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayButton(_:)), name: NSNotification.Name(rawValue: didupdatePlayDone), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayButton(_:)), name: NSNotification.Name(rawValue: didupdatePauseToMain), object: nil)
        

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //
    
    func handleTap(recognizer: UITapGestureRecognizer){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "playScene")
        self.present(secondViewController, animated:true)
        //self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    // MARK:- AVAudioPlayer Delegate's Callback method
    
    func updatePlayButton(_ notification: Notification){
        if Shared.shared.audioPlayer.isPlaying == true{
       // playButton.setTitle("Pause", for: .normal)
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        }
        else{
         //   playButton.setTitle("Play", for: .normal)
            playButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }

    
    func getSelectFromLeftTab(_ notification: Notification){
        let result = notification.object as? String
        self.selectedType = result
        for i in 0...2 {
            didSelected[i] = false
            if categoryType[i] == selectedType{
                didSelected[i] = true
            }
        }
        collectionView.reloadData()
    }
    
    func updateMainScreen(_ notification: Notification){
        audioLength = Shared.shared.audioPlayer.duration
        playProgress.maximumValue = CFloat(Shared.shared.audioPlayer.duration)
        playProgress.minimumValue = 0.0
        playProgress.value = Float(Shared.shared.audioPlayer.currentTime)
        
        playingName.text = Shared.shared.currentPlaying?.title
        playingArtist.text = Shared.shared.currentPlaying?.artist
        
        startTimer()
        if (Shared.shared.currentPlaying?.artWork == nil){
            currentArtwork.image = UIImage(named: "default")
        }
        else{
            currentArtwork.image = UIImage(data: (Shared.shared.currentPlaying?.artWork)!)
        }
        if Shared.shared.audioPlayer.isPlaying == true{
            //playButton.setTitle("Pause", for: .normal)
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        }
    }
    
    func playSelectedSong(_ notification: Notification){
        do{
            let audioPath = Bundle.main.path(forResource: Shared.shared.currentPlaying?.title, ofType: "mp3")
            try Shared.shared.audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            preparePlay()
            //Shared.shared.audioPlayer.delegate = self
            playSong()
            Shared.shared.updateInfoMPNowPlaying()
            
        }
        catch
        {
            print("ERROR")
        }

    }
    
    func preparePlay(){
        audioLength = Shared.shared.audioPlayer.duration
        playProgress.maximumValue = CFloat(Shared.shared.audioPlayer.duration)
        playProgress.minimumValue = 0.0
        playProgress.value = 0.0
        self.playingName.text = Shared.shared.currentPlaying?.title
        self.playingArtist.text = Shared.shared.currentPlaying?.artist
        currentArtwork.image = UIImage(data: (Shared.shared.currentPlaying?.artWork)!)

    }
    
    func playSong(){
        Shared.shared.playSong()
        startTimer()
        if (Shared.shared.audioPlayer.isPlaying == true) && (playButton.currentTitle == "Play"){
            //playButton.setTitle("Pause", for: .normal)
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        }

    }
    
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    
    func update(_ timer: Timer){
        if !Shared.shared.audioPlayer.isPlaying{
            return
        }
        let time = Shared.shared.calculateTimeFromNSTimeInterval(Shared.shared.audioPlayer.currentTime)
        playProgress.value = CFloat(Shared.shared.audioPlayer.currentTime)
        UserDefaults.standard.set(playProgress.value , forKey: "playerProgressSliderValue")
    }
    
    func setupNowPlayingInfoCentre() {
        try! AVAudioSession.sharedInstance().setActive(true)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
        } catch {
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        MPRemoteCommandCenter.shared().playCommand.addTarget(handler: {event in
            Shared.shared.playSong()
            self.playButton.setImage(UIImage(named: "Pause"), for: .normal)
            return .success
        })
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(handler: {event in
            Shared.shared.pauseSong()
            self.playButton.setImage(UIImage(named: "Play"), for: .normal)
            return .success
        })
    }


    
    //Play Controll
    @IBAction func play(_ sender: Any) {
        if Shared.shared.currentPlaying == nil{
            playButton.setImage(UIImage(named: "Play"), for: .normal)
        }
        else{
        if Shared.shared.audioPlayer.isPlaying == true{
            Shared.shared.pauseSong()
           // playButton.setTitle("Play", for: .normal)
            playButton.setImage(UIImage(named: "Play"), for: .normal)
        }
        else{
            Shared.shared.playSong()
            //playButton.setTitle("Pause", for: .normal)
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        }
        }
        
    }
    @IBAction func changePlayTime(_ sender: UISlider) {
        Shared.shared.audioPlayer.currentTime = TimeInterval(sender.value)
        Shared.shared.updateInfoMPNowPlaying()
    }
    @IBAction func cancelToViewController(segue:UIStoryboardSegue) {
    }
    
}

//Set CollectionView

extension ViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryType.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Media", for: indexPath) as! CollectionViewCell
        cell.label.text = categoryType[indexPath.row]
        cell.label.sizeToFit()
        if didSelected[indexPath.row]{
            cell.backgroundColor = UIColor.red
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedType = categoryType[indexPath.row]
        for i in 0...2 {
            didSelected[i] = false
        }
        didSelected[indexPath.row] = true
        collectionView.reloadData()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didChooseCategory), object: (indexPath.row + 1))
    }
}

extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didSendTheSearch), object: (searchBar.text))
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }

}


