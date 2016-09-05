//
//  EstablishmentTableViewController.swift
//  HappyHour
//
//  Created by Eric Lee on 2016-07-05.
//  Copyright © 2016 Erics App House. All rights reserved.
//

import UIKit
import Firebase



class EstablishmentTableViewController: UITableViewController {

    // MARK: Properties
    
    var establishments = [Establishment]()
    
    let currentDate = NSDate()
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //loadSampleEstablishments()
        loadEstablishments()

        // pull down to refresh:
        self.refreshControl?.addTarget(self, action: #selector(EstablishmentTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        
        
        
    }
    
    // Method to refresh the table view
    func refresh(sender:AnyObject)
    {
        /*
        for establishment in establishments {
            establishment.isOpen()
        }
        
        self.tableView.reloadData()
        
        print("I'm refreshing")
        */
        
        establishments = []
        loadEstablishments()
        self.refreshControl?.endRefreshing()
    }
    

    func loadEstablishments(){
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("establishments").queryOrderedByChild("confirmations").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let establishmentDict = snapshot.value as! [String: AnyObject]
            

            let name = establishmentDict["name"] as! String
            let description = establishmentDict["description"] as! String
            let confirmations = establishmentDict["confirmations"] as! Int
            let startDay = establishmentDict["startDay"] as! String
            let endDay = establishmentDict["endDay"] as! String
            
            let startTimeDict = establishmentDict["startTime"]
            let startTime = Time(hour: startTimeDict!["hour"] as! Int, minute: startTimeDict!["minute"] as! Int, isAM:startTimeDict!["isAM"] as! Bool)
            
            let endTimeDict = establishmentDict["endTime"]
            let endTime = Time(hour: endTimeDict!["hour"] as! Int, minute: endTimeDict!["minute"] as! Int, isAM: endTimeDict!["isAM"] as! Bool)
            
            let photoURL = establishmentDict["photoURL"] as! String
            
            let establishment = Establishment(name: name, description: description, confirmations: confirmations, startTime: startTime, endTime: endTime, startDay: startDay, endDay: endDay, photoURL: photoURL)
            
            establishment?.databaseID = snapshot.key
            
            self.establishments.insert(establishment!, atIndex: 0)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
            

  
        })
        

        
    }
    
    func loadSampleEstablishments(){
        

        let startDate = Time(hour: 3, minute: 0, isAM: false)
        let endDate = Time(hour: 6, minute: 0, isAM: false)
        
        let startDate2 = Time(hour: 2, minute: 22, isAM: true)
        let endDate2 = Time(hour: 6, minute: 22, isAM: true)
        
        let estab1 = Establishment(name: "Cactus Club", description: "Discount on drinks from 3pm to 6pm", confirmations: 0, startTime: startDate, endTime: endDate, startDay: "Monday", endDay: "Friday")!
        
        let estab2 = Establishment(name: "Earls", description: "Save on food and drinks after 9pm", confirmations: 0, startTime: startDate2, endTime: endDate2, startDay: "Monday", endDay: "Friday")!
        
        let estab3 = Establishment(name: "Guu", description: "Save on food and drinks after 9pm", confirmations: 0, startTime: startDate, endTime: endDate, startDay: "Monday", endDay: "Friday")!
        
        establishments += [estab1, estab2, estab3]
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return establishments.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "EstablishmentTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EstablishmentTableViewCell
        
        // Fetch appropriate establishment for the data source layout
        let establishment = establishments[indexPath.row]
        
        cell.nameLabel.text = establishment.name
        cell.confirmationLabel.text = "\(establishment.confirmations)👌"
        cell.timeLabel.text = (establishment.startTime.toString() as String) + " - " + (establishment.endTime.toString() as String)
        //cell.timeLabel.textColor = UIColor.blueColor()
        if establishment.openStatus {
            //cell.openCircleImage.image = UIImage(named: "greenCircle")
            cell.openCircleImage.image = UIImage.circle(10, color: UIColor.greenColor())

        } else {
            // cell.openCircleImage.image = UIImage(named: "redCircle")
            cell.openCircleImage.image = UIImage.circle(10, color: UIColor.redColor())
        }
        


        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowDetail" {
            let establishmentDetailViewController = segue.destinationViewController as! EstablishmentViewController
            
            // Get the cell that generated the segue
            if let selectedEstablishmentCell = sender as? EstablishmentTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedEstablishmentCell)!
                let selectedEstablishment = establishments[indexPath.row]
                establishmentDetailViewController.establishment = selectedEstablishment
                establishmentDetailViewController.showDetailSegueFlag = true
                
            }
            
        }
        
        else if segue.identifier == "AddEstablishment" {
            print("Adding new establishment")
        }
    }
    
    
    @IBAction func unwindToEstablishmentList(sender: UIStoryboardSegue){

        
        if let sourceViewController = sender.sourceViewController as? EstablishmentViewController, establishment = sourceViewController.establishment {
            
            let firebaseService = FirebaseService()
            
            if let selectedPath = tableView.indexPathForSelectedRow {
                firebaseService.updateEstablishment(establishment)
                
                establishments[selectedPath.row] = establishment
                tableView.reloadRowsAtIndexPaths([selectedPath], withRowAnimation: .None)
            }
            else{
                
                // Add new establishment to the firebase database
                firebaseService.saveNewEstablishment(establishment)
                
                // save the image to the firebase storage and retrieve photo url
                firebaseService.uploadImageDataToStorage(establishment)
                

                
                
                // Add new establishment to array and table
                //let newIndexPath = NSIndexPath(forRow: establishments.count, inSection: 0)
                
                //establishments.append(establishment)
                //tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                
            }
            
            
        }
    }

}
