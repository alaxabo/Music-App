//
//  ViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 6/21/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit
import AVFoundation

var didChooseLeftTab = "didChooseLeftTab"

class ViewController: UIViewController {
    
    @IBOutlet weak var tabButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var songTable: UITableView!
    @IBOutlet weak var playingName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playProgress: UISlider!
    @IBOutlet weak var currentArtwork: UIImageView!
    
    
    
    
    var categoryType = ["Songs","Albums","Artists"]
    var didSelected = [Bool](repeating: false, count: 3)
    var selectedType: String?
    var songs = [Song]()
    var audioPlayer = AVAudioPlayer()
    var thisSong = 0
    var audioLength = 0.0
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSongNames()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(getSelectFromLeftTab(_:)), name: NSNotification.Name(rawValue: didChooseLeftTab), object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //Get Song Name
    func getSongNames(){
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        var songTitle, songArtist, songAlbum: String!
        var songArtWork: Data!
        do
        {
            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for song in songPath
            {
                var mySong = song.absoluteString
                if mySong.contains(".mp3")
                {
                    let avpltem = AVPlayerItem(url: song)
                    let commonMetadata = avpltem.asset.commonMetadata
                    for i in commonMetadata{
                        if i.commonKey == "title"{
                            songTitle = i.stringValue
                        }
                        if i.commonKey == "artist"{
                            songArtist = i.stringValue
                        }
                        if i.commonKey == "albumName"{
                            songAlbum = i.stringValue
                        }
                        if i.commonKey == "artwork"{
                            songArtWork = i.dataValue
                        }
                        
                    }
                    songs.append(Song(title: songTitle, artist: songArtist, album: songAlbum, artWork: songArtWork))
                }
                
            }
        }
        catch{
            print ("ERROR")
        }
    }
    
    func preparePlay(){
        audioLength = audioPlayer.duration
        playProgress.maximumValue = CFloat(audioPlayer.duration)
        playProgress.minimumValue = 0.0
        playProgress.value = 0.0
        currentArtwork.image = UIImage(named: "default")
    }
    
    func playSong(){
        audioPlayer.play()
        startTimer()
        if (audioPlayer.isPlaying == true) && (playButton.currentTitle == "Play"){
            playButton.setTitle("Pause", for: .normal)
        }
    }
    
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    
    func update(_ timer: Timer){
        if !audioPlayer.isPlaying{
            return
        }
        let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
        playProgress.value = CFloat(audioPlayer.currentTime)
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
        //        totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        //        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }
    
    
    //Play Controll
    @IBAction func play(_ sender: Any) {
        if audioPlayer.isPlaying == true{
            audioPlayer.pause()
            playButton.setTitle("Play", for: .normal)
        }
        else{
            audioPlayer.play()
            playButton.setTitle("Pause", for: .normal)
        }
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
    }
}

//Set Song Table

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = songTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell
        cell.titleLabel?.text = songs[indexPath.row].title
        cell.artistLabel?.text = songs[indexPath.row].artist
        if songs[indexPath.row].artWork == nil{
             cell.artworkImage.image=UIImage(named: "default")
        }
        else{
        cell.artworkImage?.image = UIImage(data: songs[indexPath.row].artWork!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            let audioPath = Bundle.main.path(forResource: songs[indexPath.row].title, ofType: "mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            thisSong = indexPath.row
            self.playingName.text = songs[indexPath.row].title
            if songs[indexPath.row].artWork == nil{
                currentArtwork.image = UIImage(named: "default")
            }
            else{
                currentArtwork.image = UIImage(data: songs[indexPath.row].artWork!)
            }

            preparePlay()
            playSong()
        }
        catch
        {
            print("ERROR")
        }
    }
}


