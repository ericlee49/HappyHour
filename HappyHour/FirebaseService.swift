//
//  FirebaseService.swift
//  HappyHour
//
//  Created by Eric Lee on 2016-08-11.
//  Copyright © 2016 Erics App House. All rights reserved.
//

import UIKit
import Firebase

class FirebaseService: NSObject {
    
    let ref = FIRDatabase.database().reference()
    
    func saveNewEstablishment(establishment: Establishment) {
        let establishmentRef = ref.child("establishments").childByAutoId()
        
        let establishmentRefKey = establishmentRef.key
        
        establishment.databaseID = establishmentRefKey

        
        
        let databaseEstablishment =
            
            ["photoURL": "",
             "name": establishment.name,
             "description": establishment.description,
             "startDay": establishment.startDay,
             "endDay": establishment.endDay,
             "confirmations": establishment.confirmations,
             "startTime": [
                "hour": establishment.startTime.hour,
                "minute": establishment.startTime.minute,
                "isAM": establishment.startTime.isAM],
             "endTime": [
                "hour": establishment.endTime.hour,
                "minute": establishment.endTime.minute,
                "isAM": establishment.endTime.isAM]]
        
        establishmentRef.setValue(databaseEstablishment)
        
    }
    
    func updateEstablishment(establishment: Establishment) {
        if let establishmentRefKey = establishment.databaseID {
            ref.child("establishments/\(establishmentRefKey)/confirmations").setValue(establishment.confirmations)
            print(establishmentRefKey)
        } else {
            print("could not retrieve the reference id")
        }
    }
    
    func uploadImageDataToStorage(establishment: Establishment) {
        let storageRef = FIRStorage.storage().reference()
        
        let childID = "\(establishment.name).photo"
        
        let photo = establishment.photo
        
        if let uploadData = UIImagePNGRepresentation(photo!) {
            storageRef.child(childID).putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error)
                }
                
                //print(metadata)
                establishment.photoURL = metadata?.downloadURL()?.absoluteString
                
                
                let establishmentKey = establishment.databaseID!
                
                let establishmentRef = self.ref.child("establishments/\(establishmentKey)/photoURL")
                
                //let photoURLDatabaseEntry = ["photoURL": metadata?.downloadURL()?.path as! AnyObject]
                
                establishmentRef.setValue(metadata?.downloadURL()?.absoluteString)
                
                print("saving to STORAGE:")
                print(establishment.photoURL)
                
                
                
            })
        }
    }
}
