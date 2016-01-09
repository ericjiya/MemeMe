//
//  ViewController.swift
//  MemeMe
//
//  Created by jiya on 12/31/15.
//  Copyright © 2015 jiya. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //define text attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "Helveticaneue-CondensedBlack",size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set text fields attributes
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.borderStyle = UITextBorderStyle.None
        topTextField.backgroundColor = UIColor.clearColor()
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.borderStyle = UITextBorderStyle.None
        bottomTextField.backgroundColor = UIColor.clearColor()
        
        //hide text fields
        showOrHideTextFields(false)
        
        //hide share and cancel button
        enableShareButton(false)
        
        //delegate
        topTextField.delegate = self
        bottomTextField.delegate = self
    }

    //pick image from album
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker,animated: true, completion: nil)
    }

    //pick image from camera
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker,animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            
            //show text fields
            showOrHideTextFields(true)
            resetTextFieldsAsDefaultText()
            
            //show share and cancel button
            enableShareButton(true)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func showOrHideTextFields(show: Bool){
        if show {
            topTextField.hidden = false
            bottomTextField.hidden = false
        } else {
            topTextField.hidden = true
            bottomTextField.hidden = true
        }
    }
    
    func resetTextFieldsAsDefaultText(){
        topTextField.text = "Input a top text"
        bottomTextField.text = "Input a bottom text"
    }
    
    func enableShareButton(enable: Bool){
        shareButton.enabled = enable
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //hide tab bar
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
        //show tab bar
        self.tabBarController?.tabBar.hidden = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = nil
    }
    
    //resign first responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func save(){
        //create a meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: self.generateMemedImage())
        
        //add it to a memes array in the Application Delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        //hide tool and nav bar
        self.topNavBar.hidden = true
        self.bottomToolBar.hidden = true
        
        //render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)

        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //show tool and nav bar
        self.topNavBar.hidden = false
        self.bottomToolBar.hidden = false
        
        return memedImage
    }

    @IBAction func shareMemedImage(sender: UIBarButtonItem) {
        let memedImage = self.generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {
            (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) -> Void in
            if completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAndReturn(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}