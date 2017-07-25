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

class SongTableViewController: UITableViewController {

    @IBOutlet var songTable: UITableView!
    
    
     var category = 0
     var songs = [Song]()
     var searchSongs = [Song]()
     var albums = [Album]()
     var searchAlbums = [Album]()
     var selectedAlbum: Album?
     var artists = [Artist]()
     var searchArtists = [Artist]()
     var selectedArtist: Artist?
     var searchText: String?
     var searchChoice: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSongNames()
        getAlbums()
        getArtist()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getCategory(_:)), name: NSNotification.Name(rawValue: didChooseCategory), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSearchText(_:)), name: NSNotification.Name(rawValue: didSendTheSearch), object: nil)
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
            searchAlbums = albums.filter{
                album in return album.title.lowercased().contains((searchText?.lowercased())!)
            }
        }
        else if (category == 3){
            searchArtists = artists.filter{
                    artist in return artist.name.lowercased().contains((searchText?.lowercased())!)
            }
        }
        else
        {
        searchSongs = songs.filter{
            song in return song.title.lowercased().contains((searchText?.lowercased())!)
        }
        }
        songTable.reloadData()
    }
    
    //
    
    func getCategory(_ notification: Notification){
        let result = notification.object
        self.category = result as! Int
        songTable.reloadData()
    }
    // Get Song Name
    func getSongNames(){
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        var songTitle, songArtist, songAlbum: String!
        var songArtWork: Data!
        do
        {
            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for song in songPath
            {
                let mySong = song.absoluteString
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
                    if songTitle == nil{
                        songTitle = "Unknow Song"
                    }
                    if songArtist == nil{
                        songArtist = "Unknow Artist"
                    }
                    if songAlbum == nil {
                        songAlbum = "Unknow Album"
                    }
                    songs.append(Song(title: songTitle, artist: songArtist ?? "Unknow Artist", album: songAlbum ?? "Unknow Album", artWork: songArtWork ?? UIImagePNGRepresentation(UIImage(named: "default")!)!))
                }
            }
        }
        catch{
            print ("ERROR")
        }
    }
    // Get Album
    func getAlbums(){
        for i in songs{
            var checkAlbum = 0
            for album in albums{
                if (i.album == album.title){
                    checkAlbum = 1
                }
            }
            if (checkAlbum == 0){
                if i.artWork != nil{
                albums.append(Album(title: i.album, artist: i.artist, artwork: i.artWork))
                }
                else{
                    let image = UIImage(named: "default")
                    let data:Data = UIImagePNGRepresentation(image!)!
                    albums.append(Album(title: i.album, artist: i.artist, artwork: data))
                }
            }
        }
        
        //Add Song To Album
        for i in songs{
            for j in 0 ..< albums.count {
                if (i.album == albums[j].title){
                    albums[j].appendSong(song: i)
                }
            }
        }
    }
    // Get Artist
    func getArtist(){
        for i in songs{
            var checkArtist = 0
            for artist in artists{
                if (i.artist == artist.name){
                    checkArtist = 1
                }
            }
            if (checkArtist == 0){
                if i.artWork != nil{
                    artists.append(Artist(name: i.artist, artwork: i.artWork))
                }
                else{
                    let image = UIImage(named: "default")
                    let data:Data = UIImagePNGRepresentation(image!)!
                    artists.append(Artist(name: i.artist, artwork: data))
                }
            }
        }
        for i in songs{
            for j in 0 ..< artists.count {
                if (i.artist == artists[j].name){
                    artists[j].appendSong(song: i)
                }
            }
        }
        for album in albums{
            for i in 0 ..< artists.count{
                if (album.artist == artists[i].name){
                    artists[i].appendAlbum(album: album)
                }
            }
        }
    }
    
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
            return albums.count
            }
            else{
                return searchAlbums.count
            }
        case 3:
            if (searchText == nil){
                return artists.count
            }
            else{
                return searchArtists.count
            }

        default:
            if (searchText == nil){
                return songs.count
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
            cell.titleLabel?.text = albums[indexPath.row].title
            let a = albums[indexPath.row].albumSongs.count
            cell.artistLabel?.text = String(a) + " Songs By \(albums[indexPath.row].artist)"
            if songs[indexPath.row].artWork == nil{
                cell.artworkImage.image=UIImage(named: "default")
            }
            else{
                cell.artworkImage?.image = UIImage(data: songs[indexPath.row].artWork!)
            }
            return cell
            }
            else{
                cell.titleLabel?.text = searchAlbums[indexPath.row].title
                let a = searchAlbums[indexPath.row].albumSongs.count
                cell.artistLabel?.text = String(a) + " Songs By \(searchAlbums[indexPath.row].artist)"
                
                cell.artworkImage?.image = UIImage(data: songs[indexPath.row].artWork!)
            
                return cell

            }
        
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell
            if (searchText == nil){
            cell.titleLabel?.text = artists[indexPath.row].name
            cell.artistLabel.text = "\(artists[indexPath.row].albumName.count) Albums | \(artists[indexPath.row].allSong.count) Songs"
            if songs[indexPath.row].artWork == nil{
                cell.artworkImage.image=UIImage(named: "default")
            }
            else{
                cell.artworkImage?.image = UIImage(data: songs[indexPath.row].artWork!)
            }
            return cell
            }
            else{
                cell.titleLabel?.text = searchArtists[indexPath.row].name
                cell.artistLabel.text = "\(searchArtists[indexPath.row].albumName.count) Albums | \(searchArtists[indexPath.row].allSong.count) Songs"
                if songs[indexPath.row].artWork == nil{
                    cell.artworkImage.image=UIImage(named: "default")
                }
                else{
                    cell.artworkImage?.image = UIImage(data: songs[indexPath.row].artWork!)
                }
                return cell
            }
        default:
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell
        if (searchText == nil){
        searchChoice = 0
        cell.titleLabel?.text = songs[indexPath.row].title
        cell.artistLabel?.text = songs[indexPath.row].artist
        cell.artworkImage?.image = UIImage(data: songs[indexPath.row].artWork!)
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
            selectedAlbum = albums[indexPath.row]
            self.performSegue(withIdentifier: "albumDetail", sender: self)
        case 3:
            print("Appear Artist Detail")
            selectedArtist = artists[indexPath.row]
            self.performSegue(withIdentifier: "artistDetail", sender: self)
        default:
            if (searchChoice == 0){
            tableView.deselectRow(at: indexPath, animated: false)
            Shared.shared.currentPlaying = songs[indexPath.row]
            Shared.shared.addSongToPlayList()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectPlayingSong"), object: nil)
                
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
