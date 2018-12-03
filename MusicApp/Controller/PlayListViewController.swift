//
//  PlayListViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 7/20/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

var didupdateToPlayList = "didupdateToPlayList"

class PlayListViewController: UITableViewController, AVAudioPlayerDelegate {

    @IBOutlet var playListTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayList(_:)), name: NSNotification.Name(rawValue: didupdateToPlayList), object: nil)
        
    }
    
     @objc func updatePlayList(_ notification: Notification){
        self.playListTable.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       self.playListTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Shared.shared.playList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongTableCell
        cell.titleLabel?.text = Shared.shared.playList[indexPath.row].title
        cell.artistLabel?.text = Shared.shared.playList[indexPath.row].artist
        cell.artworkImage?.image = UIImage(data: Shared.shared.playList[indexPath.row].artWork!)
        if (Shared.shared.currentPlaying?.title == Shared.shared.playList[indexPath.row].title){
            cell.backgroundColor = .gray
        }
        else{
            cell.backgroundColor = .white
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        Shared.shared.currentPlaying = Shared.shared.playList[indexPath.row]
        do{
        let audioPath = Bundle.main.path(forResource: Shared.shared.currentPlaying?.title, ofType: "mp3")
        try Shared.shared.audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch{
            print("ERROR")
        }
        self.playListTable.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didChooseFromPlayList), object: nil)
    }
    
    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        if Shared.shared.editValue == true{
//            self.playListTable.setEditing(true, animated: true)
//            return true
//        }
//        else{
//            self.playListTable.setEditing(false, animated: true)
//            return false
//        }
//    }
    
    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//        let itemToMove = Shared.shared.playList[fromIndexPath.row]
//        Shared.shared.playList.remove(at: fromIndexPath.row)
//        Shared.shared.playList.insert(itemToMove, at: to.row)
//        playListTable.reloadData()
//    }
    
    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        if Shared.shared.editValue == true{
//            return true
//        }
//        else{
//            return false
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
    
//    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        if Shared.shared.editValue == true {
//            return .delete
//        }
//        return .none
//    }

    
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
