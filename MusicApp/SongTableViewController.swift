//
//  SongTableViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 6/22/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit
import AVFoundation

class SongTableViewController: UITableViewController {

    @IBOutlet var songTable: UITableView!
    
    
    
     var songs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSongNames()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let songTitle = songs[indexPath.row].title
        let songArtist = songs[indexPath.row].artist
        let imageData = songs[indexPath.row].artWork
        if imageData != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectPlayingSong"), object: ["songTitle":songTitle!,"songArtist":songArtist!,"imageData":imageData!])
        } else {
            let image = UIImage(named: "default")
            let data:Data = UIImagePNGRepresentation(image!)!
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectPlayingSong"), object: ["songTitle":songTitle!,"songArtist":songArtist!,"imageData":data])
        }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
