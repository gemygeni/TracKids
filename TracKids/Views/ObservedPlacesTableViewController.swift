//
//  ObsevedPlacesTableViewController.swift
//  TracKids
//
//  Created by AHMED GAMAL  on 11/1/21.
//

import UIKit
import CoreLocation

class ObservedPlacesTableViewController: UITableViewController {
    var Addresses = [Location?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchObservedPlaces()
        self.showAlert(withTitle: "Set Location", message: "press ＋ and Tap the map at desired Location  or search by address")

    }
    
    func fetchObservedPlaces(){
        Addresses = []
        
        if let trackedChildId = TrackingViewController.trackedChildUId{
            
            DataHandler.shared.fetchObservedPlaces(for: trackedChildId) {[weak self] (locations) in
                guard let locations = locations else{return}
               
               
                for location in locations{
                    DataHandler.shared.convertLocationToAdress(for: location) { (address) in

                        if   !((self?.Addresses.contains(where: { (address2) -> Bool in
                            if address2?.coordinates.latitude == address?.coordinates.latitude && address2?.coordinates.longitude == address?.coordinates.longitude {
                                return true
                            }
                            return false
                        })) ?? false){

                            self?.Addresses.append(address)

                           }
                       
                        DispatchQueue.main.async {
                                          
                            self?.tableView.reloadData()
                          }
                        }
                     }
                  }
               }
        navigationItem.rightBarButtonItem?.isEnabled = Addresses.count < 20
             }
    
    
    
    
    @IBAction func AddPlacesButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddPlacesSegue", sender: self)
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Addresses.count
          
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
 // var r = [1,2,3,4,5,6,7]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "observedPlaceCell", for: indexPath)
      //  DispatchQueue.main.async {
        cell.textLabel?.text = (self.Addresses[indexPath.row]?.title ?? "No address for this Location") + " " + (self.Addresses[indexPath.row]?.details ?? "")
      //  cell.textLabel?.text = String(r[indexPath.row])
            cell.textLabel?.numberOfLines = 0
            cell.contentView.backgroundColor = .secondarySystemBackground
            cell.backgroundColor = .secondarySystemBackground
      //  }
        return cell
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
    
//    func stopMonitoring(geotification: Geotification) {
//      for region in locationManager.monitoredRegions {
//        guard
//          let circularRegion = region as? CLCircularRegion,
//          circularRegion.identifier == geotification.identifier
//        else { continue }
//
//        locationManager.stopMonitoring(for: circularRegion)
//      }
//    }

    
}
    
    
  
    

    
