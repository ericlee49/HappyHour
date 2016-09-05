//
//  ViewController.swift
//  HappyHour
//
//  Created by Eric Lee on 2016-07-04.
//  Copyright © 2016 Erics App House. All rights reserved.
//

import UIKit
import Firebase

// MARK: Local Constants

private let days = ["","All Week", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]


class EstablishmentViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var confirmationsLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var startDayTextField: UITextField!
    @IBOutlet weak var endDayTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var openLabel: UILabel!
    
    var localStartTime: Time!
    var localEndTime: Time!
    var localStartDay: String!
    var localEndDay: String!
    var upvoteCheck = false
    var showDetailSegueFlag = false
    
    private var image: UIImage? {
        get {
            return photoImageView.image
        }
        set {
            photoImageView.image = newValue
            photoImageView.sizeToFit()
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    
    // The following value is either passed by 'EstablishmentTableViewController' in prepareForSegue(_:sender:) or constructed as part of adding a new establishment
    var establishment: Establishment?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        locationTextField.delegate = self
        descriptionTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        
        if let establishment = establishment {
            locationTextField.text = establishment.name
            descriptionTextField.text = establishment.description
            confirmationsLabel.text = " \(establishment.confirmations) Confirmations"
            
            self.localStartTime = establishment.startTime
            self.localEndTime = establishment.endTime
            startTimeTextField.text = "Start: \(establishment.startTime.toString())"
            endTimeTextField.text = "End: \(establishment.endTime.toString())"
            
            self.localStartDay = establishment.startDay
            self.localEndDay = establishment.endDay
            startDayTextField.text = "Start: \(establishment.startDay)"
            endDayTextField.text = "End: \(establishment.endDay)"
            
            openLabel.text = "\(establishment.openStatus)"
            if establishment.openStatus {
                openLabel.text = "Happy Hour is on now "
                openLabel.textColor = UIColor.greenColor()
            } else {
                openLabel.text = "Happy hour has ended 🔴"
            }
            
            
            /*
             if let establishmentPhoto = establishment.photo {
             photoImageView.image = establishmentPhoto
             } else if showDetailSegueFlag { // check if we are in show detail, so we can hide
             photoImageView.hidden = true
             }
             */
            if let establishmentPhotoURL = NSURL(string: establishment.photoURL!){
                imageURL = establishmentPhotoURL
            }
            
            
        }
        
        if showDetailSegueFlag {
            locationTextField.hidden = true
            locationTextField.userInteractionEnabled = false
            navigationItem.title = establishment!.name
        } else {
            // Otherwise we are adding a new establishment
            confirmationsLabel.hidden = true
            upvoteButton.hidden = true
            
        }
        
        checkValidEstablishmentName()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    // MARK: Image Fetching
    
    func fetchImage() {
        if let url = imageURL {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                let contentsOfURL = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue(), { 
                    if let imageData = contentsOfURL {
                        self.image = UIImage(data: imageData)
                    }
                })
                
                
            })
            
            
        }
        
    }
    
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidEstablishmentName()
        if locationTextField === textField {
            navigationItem.title = textField.text
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide keyboard
        if locationTextField === textField || descriptionTextField === textField {
            textField.resignFirstResponder()
            return true
        }
        else {
           return false
        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if locationTextField === textField || descriptionTextField === textField || startTimeTextField === textField || endTimeTextField === textField{
            // Disable save button while editing
            saveButton.enabled = false
        }
    }
    
    func checkValidEstablishmentName(){
        // Disable save button if establishment name is empty
        let text = locationTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    
    
    // MARK: Time Selection
    
    
    // Start time Action
    @IBAction func startTimeEditing(sender: UITextField) {
        print("began start time edit")
        let inputView = setupCustomInputView("start")
        sender.inputView = inputView
    }

    
    // End time Action
    @IBAction func endTimeEditing(sender: UITextField) {
        print("began end time edit")
        let inputView = setupCustomInputView("end")
        sender.inputView = inputView
    }
    
    func setupCustomInputView(id:String) -> UIView {
        let inputView = UIView(frame: CGRect(x: 0,y: 0, width: self.view.frame.width, height: 260))
        
        let datePickerView:UIDatePicker = UIDatePicker(frame: CGRect(x: (self.view.frame.width/2) - 150, y: 0, width: 0, height: 0))
        datePickerView.datePickerMode = UIDatePickerMode.Time
        datePickerView.minuteInterval = 30
        //add date picker to UIView
        inputView.addSubview(datePickerView)
        
        let doneButton = addDoneButtonToFrameBasedOnView(datePickerView)
        // add done button to UIView
        inputView.addSubview(doneButton)
        
        if id == "end" {
            datePickerView.addTarget(self, action: #selector(EstablishmentViewController.handleEndDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        } else if (id == "start") {
            datePickerView.addTarget(self, action: #selector(EstablishmentViewController.handleStartDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
        
        return inputView
    }
    
    func handleStartDatePicker(sender: UIDatePicker) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.localStartTime = sender.date.toTime()
        startTimeTextField.text = "Start: \(timeFormatter.stringFromDate(sender.date))"
        
    }
    
    func handleEndDatePicker(sender: UIDatePicker) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.localEndTime = sender.date.toTime()
        print(sender.date)
        
        endTimeTextField.text = "End: \(timeFormatter.stringFromDate(sender.date))"
        
    }
    
    func addDoneButtonToFrameBasedOnView(view: UIView) -> UIButton {
        
        let doneButton = UIButton(frame: CGRect(x: (self.view.frame.width) - 100, y: view.frame.height - 20, width: 100, height: 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        doneButton.addTarget(self, action: #selector(EstablishmentViewController.doneAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return doneButton
    }
    
    func doneAction(sender:UIButton) {
        print("done button pressed")
        self.view.endEditing(true)
    }
 
    
    // MARK: Day Selection
    
    var startOrEndDayIndicator = true
    
    @IBAction func startDayPicker(sender: UITextField) {
        self.startOrEndDayIndicator = true
        print("began start day picker")
        let inputView = setupCustomDayInputView()
        sender.inputView = inputView

    }
    
    @IBAction func endDayPicker(sender: UITextField) {
        print("began end day picker")
        self.startOrEndDayIndicator = false
        let inputView = setupCustomDayInputView()
        sender.inputView = inputView
    }
    
    func setupCustomDayInputView() -> UIView {
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 260))
        let dayPickerView = UIPickerView(frame: CGRect(x: (self.view.frame.width/2) - 170, y: 0, width: 0, height: 0))
        dayPickerView.delegate = self
        inputView.addSubview(dayPickerView)
        
        let doneButton = addDoneButtonToFrameBasedOnView(dayPickerView)
        inputView.addSubview(doneButton)
        
        return inputView
    }
    
    
    
   
    
    // MARK: PickerView Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return days[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if startOrEndDayIndicator {
            // if selected all week, fill end day with all week as well
            // Currently all week value in array is at index 1
            if row == 1 {
                startDayTextField.text = days[row]
                endDayTextField.text = days[row]
                localStartDay = days[row]
                localEndDay = days[row]
            } else {
                startDayTextField.text = "Start: \(days[row])"
                localStartDay = days[row]
            }
        } else {
            endDayTextField.text = "End: \(days[row])"
            localEndDay = days[row]
        }
        
    }

    
    
    
    // MARK: Upvote
    
    @IBAction func upvoteButton(sender: UIButton) {
        upvoteCheck = true
        establishment!.confirmations += 1
        let disableMyButton = sender
        disableMyButton.enabled = false
        confirmationsLabel.text = "\(establishment!.confirmations) Confirmations"
        navigationItem.leftBarButtonItem?.enabled = false
    }

    // MARK: Navigation
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on the style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways
        let isPresentingInAddEstablishmentMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEstablishmentMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
        
        
    }
    
    /*
    
    func uploadImageDataToStorage(photo: UIImage, photoName name: String) -> String?{
        let storageRef = FIRStorage.storage().reference()
        
        let childID = "\(name).photo"
        
        
        if let uploadData = UIImagePNGRepresentation(photo) {
            storageRef.child(childID).putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error)
                }
                
                //print(metadata)
                let urlString = metadata?.downloadURL()?.path
                return urlString
                
            })
        }
    }
 
 */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            if showDetailSegueFlag {
                print("done show detail")
            } else {
                let establishmentName = locationTextField.text ?? ""
                let description = descriptionTextField.text ?? ""
                let startDay = self.localStartDay
                let endDay = self.localEndDay
                let photo = photoImageView.image
                let upvote = 1
                
                
                
                
                
                
                //set establishment to be paseed to EstablishmentTableViewController after unwind segue
                print("startTime: \(self.localStartTime.toString())")
                print("endTime: \(self.localEndTime.toString())")
                
                establishment = Establishment(name: establishmentName, description: description, confirmations: upvote, startTime: self.localStartTime, endTime: self.localEndTime, startDay: startDay, endDay: endDay, photo: photo!)
            }
            
            
            

            
            
            
        }
    }
    
    // MARK: UIImagePikcerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dimiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original
        //let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        // Set photoImageView to display the selexted image.
        photoImageView.image = selectedImageFromPicker 
        
        // Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Image Actions Tap Gesture Recognizer
    

    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        
        if showDetailSegueFlag {
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = .blackColor()
            newImageView.contentMode = .ScaleAspectFit
            newImageView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(EstablishmentViewController.dismissFullscreenImage(_:)))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            
            // Tap again message
            let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
            label.center = CGPointMake((self.view.frame.width)/2, 150)
            label.textAlignment = NSTextAlignment.Center
            label.text = "Tap Photo Again to Close"
            label.textColor = UIColor.whiteColor()
            self.view.addSubview(label)
        } else {
            // UIImagePickerController is a view controller that lets a user pick media from their photo library
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            //imagePickerController.sourceType = .PhotoLibrary
            
            imagePickerController.allowsEditing = true
            
            // Make sure ViewController is notified when the user picks an image
            imagePickerController.delegate = self
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
        
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }


}

