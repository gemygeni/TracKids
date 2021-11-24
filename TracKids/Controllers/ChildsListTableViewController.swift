//
//  ChildsListTableViewController.swift
//  TracKids
//
//  Created by AHMED GAMAL  on 8/30/21.
//

import UIKit
import Firebase

class ChildsListTableViewController: UITableViewController {
    
    var childs = [User]()
    var childsID = [String]()
    @IBAction func AddChildPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddChildSegue", sender: self)
               }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchChildInfo()
       navigationItem.title = "Childs List"
           }
    
     func fetchChildInfo(){
        DataHandler.shared.fetchChildInfo() { (child,childID) in
            print(child.name)
            self.childs.append(child)
            self.childsID.append(childID)
             DispatchQueue.main.async {
                 self.tableView.reloadData()
                if self.childs.count > 1 {
                let indexPath = IndexPath(row: self.childs.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
             }
         }
     }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    // MARK: - Table view data source
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childs.count
    }

    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        if let childCell =  cell as? ChildsListTableViewCell {
             //Configure the cell...
            let child = childs[indexPath.row]
            childCell.textLabel?.text = child.name
            childCell.detailTextLabel?.text = child.phoneNumber
            
            if let childImageURl = child.imageURL {
                print("Debug: \(String(describing: child.imageURL))")
                childCell.profileImageView.loadImageUsingCacheWithUrlString(childImageURl)
            }
         }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowChildProfileSegue", sender: self)
    }
  
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
  

   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
   


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if  segue.identifier == "ShowChildProfileSegue"{
            if let childProfileVC = segue.destination.contents as? ChildProfileViewController{
                if let indexPath = tableView.indexPathForSelectedRow , let cell = tableView.cellForRow(at: indexPath) as? ChildsListTableViewCell  {
                    childProfileVC.name = cell.textLabel?.text
                    childProfileVC.phone = cell.detailTextLabel?.text
                    childProfileVC.fetchedImage = cell.profileImageView.image
                    childProfileVC.childID = childsID[indexPath.row]
                    TrackingViewController.trackedChildUId = childsID[indexPath.row]
                }
            }
        }
    }
}

