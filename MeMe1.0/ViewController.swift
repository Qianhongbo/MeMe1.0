//
//  ViewController.swift
//  MeMe1.0
//
//  Created by Maverick on 2021/12/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: IBOutlet
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: TextField text attributes
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.backgroundColor: UIColor.clear,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5.0
        ]
    
    // MARK: viewDidLoad fucntion
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField(textField: self.textField1)
        setupTextField(textField: self.textField2)
        // disable the share button
        self.shareButton.isEnabled = false
    }
    
    func setupTextField(textField: UITextField) {
        // set the delegate of the textField (UITextFieldDelegate)
        textField.delegate = self
        // set the textField text attributes
        textField.defaultTextAttributes = memeTextAttributes
        // set the text in the center after setting the text attributes
        textField.textAlignment = .center
    }
    
    // MARK: viewWillAppear function
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // subscribe to the keyboard notification
        subscribeToKeyboardNotifications()
        // disable the camera button if the camera can not be obtained.
        self.cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // MARK: viewWillDisappear function
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // unsubscribe to the keyboard notification
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: The function of UIImagePickerControllerDelegate, 'Tells the delegate that the user picked a still image or movie.'. Get the selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // show the selected image in the imageView
            imagePickerView.image = image
        }
        // Enable the share button
        self.shareButton.isEnabled = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Pick the image from the album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        presentPickerViewController(source: .photoLibrary)
    }
    
    // MARK: Pick the image from the camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        presentPickerViewController(source: .camera)
    }
    
    func presentPickerViewController(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self // UIImagePickerControllerDelegate, UINavigationControllerDelegate
        pickerController.sourceType = source // from album or camera
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: Delete the initial text of the textField
    // Use tag to judge whether it is the top textField or the bottom textField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 || textField.text == "TOP" {
            textField.text = ""
        }
        if textField.tag == 1 || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    // MARK: Set the return button of the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Subscribe notification function
    func subscribeToKeyboardNotifications() {
        // subscribe to: keyboardWillShowNotification
        // when receive the notification, implement keyboardWillShow function: move the view of the frame
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Subscribe notification function
    // removeObserver
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Move the keyboard with the keyboard height using getKeyboardHeight function
    @objc func keyboardWillShow(_ notification: Notification) {
        if self.textField2.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    // MARK: Move the keyboard back
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    // MARK: Get the keyboard height using "notification.userInfo"
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Hide items on the screen and get the image from the screen
    func generateMemedImage() -> UIImage {
        self.hideItem(temp: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.hideItem(temp: false)
        return memedImage
    }
    
    // MARK: Hide or show the item on the screen
    func hideItem(temp: Bool) {
        self.toolBar.isHidden = temp
        self.shareButton.isHidden = temp
        self.cancelButton.isHidden = temp
    }
    
    // MARK: Save the text and the image to the Meme struct
    func save() {
        let _ = Meme(topText: self.textField1.text!,
                     bottomText: self.textField2.text!,
                     originalImage: self.imagePickerView.image!,
                     memedImage: generateMemedImage())
    }
    
    // MARK: Share button function
    @IBAction func shareMeme(_ sender: Any) {
        // Generate a memed image
        let image = generateMemedImage()
        // Define an instance of the ActicityViewController
        // Pass the ActivityViewController a memedImage as an activity item
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        // Present the ActivityViewController
        present(controller, animated: true, completion: nil)
        // Only save the image after the user shared the image
        controller.completionWithItemsHandler = {
            (activity, completed, items, error) in
            if completed {
                self.save()
            }
        }
    }
    
    // MARK: Cancel button function
    @IBAction func cancelAction(_ sender: Any) {
        self.shareButton.isEnabled = false // Disable the share button
        self.imagePickerView.image = nil // clear the image view
        self.textField1.text = "TOP" // reset the top text field
        self.textField2.text = "BOTTOM" // reset the bottom text field
    }
    
    
}

