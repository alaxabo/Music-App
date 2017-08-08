//
//  SongTableViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 6/22/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit
import AVFoundation

var didChooseCategory = "didChooseCategory"
var didSendTheSearch = "didSendTheSearch"
var didSendTheSearchNull = "didSendTheSearchNull"

class SongTableViewController: UITableViewController {

    @IBOutlet var songTable: UITableView!
    
    
     var category = 0
     var searchSongs = [Song]()
    
     var searchAlbums = [Album]()
     var selectedAlbum: Album?
    
     var searchArtists = [Artist]()
     var selectedArtist: Artist?
     var searchText: String?
     var searchChoice: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Shared.shared.getSongNames()
        Shared.shared.getAlbums()
        Shared.shared.getArtist()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getCategory(_:)), name: NSNotification.Name(rawValue: didChooseCategory), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSearchText(_:)), name: NSNotification.Name(rawValue: didSendTheSearch), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSearchTextNull(_:)), name: NSNotification.Name(rawValue: didSendTheSearchNull), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Get Search
    func getSearchText(_ notification: Notification){
        let result = notification.object
        self.searchText = result as! String?
        if (category == 2){
            searchAlbums = Shared.shared.albums.filter{
                album in return album.title.lowercased().contains((searchText?.lowercased())!)
            }
        }
        else if (category == 3){
            searchArtists = Shared.shared.artists.filter{
                    artist in return artist.name.lowercased().contains((searchText?.lowercased())!)
            }
        }
        else
        {
        searchSongs = Shared.shared.songs.filter{
            song in return song.title.lowercased().contains((searchText?.lowercased())!)
        }
        }
        songTable.reloadData()
    }
    
    func getSearchTextNull(_ notification: Notification){
        searchText = " "
        songTable.reloadData()
    }
    
    //
    
    func getCategory(_ notification: Notification){
        let result = notification.object
        self.category = result as! Int
        songTable.reloadData()
    }
    // Get Song Name
        
    //Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumDetail" {
            let destionation1 = segue.destination as? AlbumDetailViewController
            destionation1?.selectedAlbum = selectedAlbum
        }
        if segue.identifier == "artistDetail"{
            let destination = segue.destination as? ArtistDetailViewController
            destination?.selectedArtist = selectedArtist
        }
    }
    
    @IBAction func cancelToViewController(segue:UIStoryboardSegue) {
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch category {
        case 2:
            if (searchText == nil){
            return Shared.shared.albums.count
            }
            else{
                return searchAlbums.count
            }
        case 3:
            if (searchText == nil){
                return Shared.shared.artists.count
            }
            else{
                return searchArtists.count
            }

        default:
            if (searchText == nil){
                return Shared.shared.songs.count
            }
            else{
                return searchSongs.count
            }
        }
    
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch category {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell
            if (searchText == nil)
            {
            searchChoice = 0
            cell.titleLabel?.text = Shared.shared.albums[indexPath.row].title
            let a = Shared.shared.albums[indexPath.row].albumSongs.count
            if Shared.shared.albums[indexPath.row].title == "Unknow Album"{
                cell.artistLabel?.text = String(a) + " Songs"
            }
                else{
                    cell.artistLabel?.text = String(a) + " Songs By \(Shared.shared.albums[indexPath.row].artist)"
                }
            cell.artworkImage?.image = UIImage(data: Shared.shared.albums[indexPath.row].artwork!)
        
            return cell
            }
            else{
                cell.titleLabel?.text = searchAlbums[indexPath.row].title
                let a = searchAlbums[indexPath.row].albumSongs.count
                cell.artistLabel?.text = String(a) + " Songs By \(searchAlbums[indexPath.row].artist)"
                cell.artworkImage?.image = UIImage(data: searchAlbums[indexPath.row].artwork!)
                searchChoice = 1
                searchText = nil
                return cell

            }
        
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell
            if (searchText == nil){
            searchChoice = 0
            cell.titleLabel?.text = Shared.shared.artists[indexPath.row].name
            cell.artistLabel.text = "\(Shared.shared.artists[indexPath.row].albumName.count) Albums | \(Shared.shared.artists[indexPath.row].allSong.count) Songs"
            
            cell.artworkImage?.image = UIImage(data: Shared.shared.artists[indexPath.row].artwork)
            
            return cell
            }
            else{
                cell.titleLabel?.text = searchArtists[indexPath.row].name
                cell.artistLabel.text = "\(searchArtists[indexPath.row].albumName.count) Albums | \(searchArtists[indexPath.row].allSong.count) Songs"
                if searchArtists[indexPath.row].artwork == nil{
                    cell.artworkImage.image=UIImage(named: "default")
                }
                else{
                    cell.artworkImage?.image = UIImage(data: searchArtists[indexPath.row].artwork)
                }
                searchChoice = 1
                searchText = nil
                return cell
            }
        default:
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell
        if (searchText == nil){
        searchChoice = 0
        cell.titleLabel?.text = Shared.shared.songs[indexPath.row].title
        cell.artistLabel?.text = Shared.shared.songs[indexPath.row].artist
        cell.artworkImage?.image = UIImage(data: Shared.shared.songs[indexPath.row].artWork!)
        return cell
        }
        else
        {
            cell.titleLabel?.text = searchSongs[indexPath.row].title
            cell.artistLabel?.text = searchSongs[indexPath.row].artist
            cell.artworkImage?.image = UIImage(data: searchSongs[indexPath.row].artWork!)
            searchText = nil
            searchChoice = 1
            return cell
            
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch category{
        case 2:
            if (searchChoice == 0){
            selectedAlbum = Shared.shared.albums[indexPath.row]
            }
            else{
                selectedAlbum = searchAlbums[indexPath.row]
            }
            self.performSegue(withIdentifier: "albumDetail", sender: self)
        case 3:
            if (searchChoice == 0){
            selectedArtist = Shared.shared.artists[indexPath.row]
            }
            else{
                 selectedArtist = searchArtists[indexPath.row]
            }
            self.performSegue(withIdentifier: "artistDetail", sender: self)
        default:
            if (searchChoice == 0){
            tableView.deselectRow(at: indexPath, animated: false)
            Shared.shared.currentPlaying = Shared.shared.songs[indexPath.row]
            Shared.shared.addSongToPlayList()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectPlayingSong"), object: nil)
                
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "playScreenID") as UIViewController
            self.present(vc, animated: true, completion: nil)
            }
            else{
                
                Shared.shared.currentPlaying = searchSongs[indexPath.row]
                Shared.shared.addSongToPlayList()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectPlayingSong"), object: nil)
                
            }
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
