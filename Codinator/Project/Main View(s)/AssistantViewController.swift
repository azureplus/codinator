//
//  AssistantViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 22/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit


protocol AssistantViewControllerDelegate: class {
    
    /// Selects a file, retruns true if the files exists
    func selectFileWithName(name: String) -> Bool
}


class AssistantViewController: UIViewController, SnippetsDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var fileNameTextField: UITextField?
    @IBOutlet var fileExtensionTextField: UITextField?
    
    @IBOutlet weak var pathLabel: UILabel!
    
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var modifiedLabel: UILabel!
    
    
    
    @IBOutlet weak var snippetsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var snippetsSegmentControl: UISegmentedControl!
    
    
    weak var delegate: SnippetsDelegate?
    var renameDelegate: AssistantViewControllerDelegate?
    
    var projectManager: Polaris?
    var prevVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let polaris = projectManager {
            self.setFilePathTo(polaris)
            self.navigationItem.title = "Utilities"
        }
        else {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: snippetsViewHeightConstraint.constant, right: 0)
            
            scrollView.scrollIndicatorInsets = insets
            scrollView.contentInset = insets
        }
        
       
        fileNameTextField?.delegate = self
        fileExtensionTextField?.delegate = self
    
    }
    
    var fileUrl: NSURL?
    func setFilePathTo(projectManager: Polaris) {
        
        fileUrl = projectManager.selectedFileURL
        
        fileNameTextField!.text = fileUrl?.URLByDeletingPathExtension?.lastPathComponent
        fileExtensionTextField!.text = fileUrl?.pathExtension
        
        pathLabel.text = projectManager.fakePathForFileSelectedFile()
        
        do {
            let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(projectManager.selectedFileURL!.path!)
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            
            let fileSize = (attributes["NSFileSize"] as! Int)
            let createdDate = attributes["NSFileCreationDate"] as! NSDate
            let modifiedDate = attributes["NSFileModificationDate"] as! NSDate
            
            fileSizeLabel.text = "Size: \(fileSize) B"
            createdLabel.text = "Created: " + dateFormatter.stringFromDate(createdDate)
            modifiedLabel.text = "Modified: " + dateFormatter.stringFromDate(modifiedDate)
            
            
        } catch {
            
            fileSizeLabel.text = "Failed loading file size"
            createdLabel.text = "Failed loading created date"
            modifiedLabel.text = "Failed loading modified date"
            
            
        }
        
    }
    
    
    @IBOutlet weak var enumerationButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var colorPicker: UIButton!
    
    @IBAction func segmendDidChange(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            enumerationButton.hidden = false
            imageButton.hidden = false
            linkButton.hidden = false
            
            colorPicker.hidden = true
        }
        else {
            enumerationButton.hidden = true
            imageButton.hidden = true
            linkButton.hidden = true
            
            colorPicker.hidden = false
        }
    }
    
    
    
    // MARK: - Snippets delegate
    
    func snippetWasCoppied(status: String) {
        delegate?.snippetWasCoppied(status)
    }
    
    func colorDidChange(color: UIColor) {
        delegate?.colorDidChange(color)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TextFieldDelegate
    
    var previosText: String?
    func textFieldDidBeginEditing(textField: UITextField) {
        if fileExtensionTextField!.text == "" && fileNameTextField!.text == "" {
            textField.resignFirstResponder()
        }
        else {
            previosText = textField.text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if previosText != textField.text {
            
            if fileNameTextField?.text == "" {
                Notifications.sharedInstance.alertWithMessage(nil, title: "Filename cant be empty", viewController: self)
                fileNameTextField?.becomeFirstResponder()
            }
            else {
                let fileManager = NSFileManager.defaultManager()
                
                do {
                    try fileManager.moveItemAtURL(fileUrl!, toURL: fileUrl!.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(fileNameTextField!.text! + "." + fileExtensionTextField!.text!))
                    
                    self.renameDelegate?.selectFileWithName(fileNameTextField!.text! + "." + fileExtensionTextField!.text!)
                    
                } catch let error as NSError {
                    Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Something went wrong!", viewController: self)
                }
            }
        }
        
        return false
        
    }
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "img":
            let vc = segue.destinationViewController as! UINavigationController
            (vc.viewControllers.first as! ImgSnippetsViewController).delegate = self
            
        case "link":
            let vc = segue.destinationViewController as! UINavigationController
            (vc.viewControllers.first as! LinkSnippetsViewController).delegate = self
            
        case "list":
            let vc = segue.destinationViewController as! UINavigationController
            (vc.viewControllers.first as! ListSnippetsViewController).delegate = self
            
        case "colorPicker":
            let vc = segue.destinationViewController as! UINavigationController
            (vc.viewControllers.first as! ColorPickerViewController).delegate = self
            
        default:
            break
        }
    }
   
    // MARK: - Trait collection
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if size.width > 507 && projectManager != nil && prevVC != nil {
            prevVC?.navigationController?.popViewControllerAnimated(true)
        }
    
    }
    

}
