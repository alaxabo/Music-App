//
//  QueueViewController.swift
//  MusicApp
//
//  Created by Alaxabo on 7/25/17.
//  Copyright © 2017 Alaxabo. All rights reserved.
//

import UIKit

class QueueViewController: UITableViewController {

    @IBOutlet var playListTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        playListTable.isEditing = true
        
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
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = Shared.shared.playList[fromIndexPath.row]
        Shared.shared.playList.remove(at: fromIndexPath.row)
        Shared.shared.playList.insert(itemToMove, at: to.row)
        playListTable.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if Shared.shared.playList[indexPath.row].title != Shared.shared.currentPlaying?.title {
                Shared.shared.playList.remove(at: indexPath.row)
            } else {
                let message = UIAlertController(title: nil, message: "Cannot Remove Playing Song <3", preferredStyle: UIAlertController.Style.alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                message.addAction(cancel)
                self.present(message, animated: true, completion: nil)
            }
        }
        playListTable.reloadData()
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
