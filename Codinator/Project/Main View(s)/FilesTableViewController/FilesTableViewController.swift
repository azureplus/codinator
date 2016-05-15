//
//  FilesTableViewController.swift
//  Codinator
//
//  Created by Lennart Kerkvliet on 26-03-16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class FilesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewFilesDelegate, AssistantViewControllerDelegate{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    
    var documentInteractionController: UIDocumentInteractionController?
    
    var items: [NSURL] = []
    
    
    var inspectorURL: NSURL?
    var projectManager: Polaris! {
        
        get {
            return getSplitView.projectManager
        }
        
    }
    
    
    var indexPath: NSIndexPath?
    
    var getSplitView: ProjectSplitViewController! {
        
        get {
            
            guard let splitView = self.splitViewController as? ProjectSplitViewController else {
                assertionFailure("SplitView is nil")
                return ProjectSplitViewController()
            }
            
            return splitView
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = inspectorURL { } else {
            inspectorURL = projectManager.inspectorURL
        }
        
        
        reloadData()
        
    
        let insets = UIEdgeInsetsMake(0, 0, toolBar.frame.height, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: self.tableView)
        }
        
    }

    
    var hasntOpenIndexFileYet = true
    
    var count = 0
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if count > 0 {
            projectManager.inspectorURL = inspectorURL
        }
                
        // Keyboard show/hide notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
            if hasntOpenIndexFileYet {
                // Find 'index.html' and save index of it in the array itself
                let items = self.items.enumerate().filter { $0.element.absoluteString.hasSuffix("index.html")}
                
                // if 'items' isn't empty sellect the corresponding cell
                if items.isEmpty != true {
                    
                    if self.getSplitView.view.traitCollection.horizontalSizeClass != .Compact {
                        let indexPath = NSIndexPath(forRow: items.first!.index, inSection: 0)
                        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
                        tableView(tableView, didSelectRowAtIndexPath: indexPath)
                    }
                    
                    // Load WebView
                    guard let webView = getSplitView.webView else {
                        return
                    }
                    
                    let url = projectManager.inspectorURL.URLByAppendingPathComponent(items.first!.element.lastPathComponent!)
                    
                    webView.loadFileURL(url, allowingReadAccessToURL: url.URLByDeletingLastPathComponent!)
                    
                    
                    hasntOpenIndexFileYet = false
                }
                else {
                    
                    
                    if self.items.count != 0 {
                        // No index file
                        
                        if getSplitView.collapsed == false {
                            
                            if self.getSplitView.view.traitCollection.horizontalSizeClass != .Compact {
                                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
                                tableView(tableView, didSelectRowAtIndexPath: indexPath)
                            }
                            
                            // Load WebView
                            guard let webView = getSplitView.webView else {
                                return
                            }
                            
                            guard let path = projectManager.inspectorURL.URLByAppendingPathComponent(self.items.first!.lastPathComponent!).path else {
                                return
                            }
                            
                            webView.loadFileURL( NSURL(fileURLWithPath: path, isDirectory: false), allowingReadAccessToURL: NSURL(fileURLWithPath: path, isDirectory: true))
                        }
                        
                        hasntOpenIndexFileYet = false
                        
                    }
                    
                    
                }
        }

        
        getSplitView.assistantViewController?.renameDelegate = self
    
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: "relaodData", object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Assistant View
    
    func selectFileWithName(name: String) {
        reloadData()
        
        // Find 'name' and save index of it in the array itself
        let items = self.items.enumerate().filter { $0.element.absoluteString.hasSuffix(name)}
        
        // if 'items' isn't empty sellect the corresponding cell
        if items.isEmpty != true {
            let indexPath = NSIndexPath(forRow: items.first!.index, inSection: 0)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
            tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
        
        
        
    }
    
    

    // MARK: - Action Buttons
    
    @IBAction func add(sender: UIBarButtonItem) {
        let newFile = UIAlertAction(title: "New File", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("newFile", sender: self)
        }
        
        let newSubpage = UIAlertAction(title: "New Subpage", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("newSubpage", sender: self)
        }
        
        let newDir = UIAlertAction(title: "New Directory", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("newDir", sender: self)
        }
        
        let Import = UIAlertAction(title: "Import", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("import", sender: self)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            
            if self.getSplitView.displayMode == .PrimaryHidden {
                self.getSplitView.preferredDisplayMode = .PrimaryOverlay
            }
            
        })

        
        
        let popup = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        popup.addAction(newFile)
        popup.addAction(newSubpage)
        popup.addAction(newDir)
        popup.addAction(Import)
        popup.addAction(cancel)
        
        popup.view.tintColor = UIColor.purpleColor()
        
        popup.popoverPresentationController?.barButtonItem = sender
        
        if getSplitView.displayMode != .PrimaryOverlay {
            self.presentViewController(popup, animated: true, completion: nil)
        }
        else {
            
            popup.title = "Product"
            
            getSplitView.preferredDisplayMode = .PrimaryHidden
            getSplitView!.rootVC.presentViewController(popup, animated: true, completion: nil)
        }
    }
    
    @IBAction func product(sender: UIBarButtonItem) {
        let run = UIAlertAction(title: "Full Screen Preview", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("run", sender: self)
        }
        
        let archive = UIAlertAction(title: "Commit", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("archive", sender: self)
        }
        
        let history = UIAlertAction(title: "Commit History", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("history", sender: self)
        }
        
        let export = UIAlertAction(title: "Export", style: .Default) { (action : UIAlertAction) in
            Notifications.sharedInstance.alertWithMessage("Archive the Project first.\nAfterwards open up the History window and use the export manager.", title: "Export")
        }
        
        let localServer = UIAlertAction(title: "Local Server", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("Pulse", sender: self)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in

            if self.getSplitView.displayMode == .PrimaryHidden {
                self.getSplitView.preferredDisplayMode = .PrimaryOverlay
            }
    
        })
        
        
        let popup = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        popup.addAction(run)
        popup.addAction(archive)
        popup.addAction(history)
        popup.addAction(export)
        popup.addAction(localServer)
        popup.addAction(cancel)
        
        popup.view.tintColor = UIColor.purpleColor()
        
        popup.popoverPresentationController?.barButtonItem = sender

        //        self.presentViewController(popup, animated: true, completion: {
//            popup.view.tintColor = UIColor.purpleColor()
//        })
        
        if getSplitView.displayMode != .PrimaryOverlay {
            self.presentViewController(popup, animated: true, completion: nil)
        }
        else {
            
            popup.title = "Product"
            
            getSplitView.preferredDisplayMode = .PrimaryHidden
            getSplitView!.rootVC.presentViewController(popup, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func navigateBackDidPush(sender: AnyObject) {
        if self.navigationController?.viewControllers.count != 1 {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    
    // MARK: - Keyboard show/hide
    
    let grabberViewHeight = CGFloat(10)
    var keyboardHeight: CGFloat = 0
    
    func keyboardWillShow(notification: NSNotification) {
//        let userInfo = notification.userInfo!
//        keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        

    }
    
    func keyboardWillHide(notification: NSNotification) {
//        keyboardHeight = 0
//        
//        var insets = tableView.contentInset
//        insets.bottom = 0
//        
//        tableView.contentInset = insets
//        tableView.scrollIndicatorInsets = insets
        
    }

    

    
    
    // MARK: - File Database
    
    func reloadData() {
        
        
        if let items = projectManager!.contentsOfDirectoryAtPath(inspectorURL?.path) {
            self.items = items.map { $0 as! NSURL}
        }

         let ip = tableView.indexPathForSelectedRow
        
        tableView.reloadData()
        
        if let indexPath = ip {
            tableView(tableView, didSelectRowAtIndexPath: indexPath)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Top )
        }

        
    }
    
    

    // MARK: - Storyboards
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
               
            case "newFile":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateFileViewController
                viewController.path = projectManager.inspectorURL.path
                viewController.items = self.items.map { $0.lastPathComponent! }
                viewController.delegate = self
 
            case "newSubpage":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateSubpageViewController
                viewController.projectManager = projectManager
                viewController.delegate = self
                
            case "newDir":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateDirViewController
                viewController.projectManager = projectManager
                viewController.delegate = self
                
            case "import":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! NewImportViewController
               
                viewController.items = self.items.map{ $0.lastPathComponent! }
                viewController.webUploaderURL = projectManager.webUploaderServerURL()
                viewController.inspectorPath = projectManager.inspectorURL.path
                viewController.delegate = self
            
            case "run":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! AspectRatioViewController
                
                if projectManager.deleteURL?.path!.characters.count >= 2 {
                    viewController.previewURL = projectManager.deleteURL
                    projectManager.deleteURL = NSURL(string: "")
                }
                else {
                
                    if let tmpPath = projectManager.tmpFileURL {
                        if tmpPath.path!.isEmpty {
                            
                            if projectManager.inspectorURL.lastPathComponent != "index.html" {
                                viewController.previewURL = projectManager.inspectorURL.URLByAppendingPathComponent("index.html")
                            }
                            else {
                                viewController.previewURL = projectManager.inspectorURL
                            }
                            
                        }
                        else {
                            viewController.previewURL = projectManager.tmpFileURL
                            projectManager.tmpFileURL = NSURL(string: "")
                        }
                    }
                    else {
                        if projectManager.inspectorURL.lastPathComponent != "index.html" {
                            viewController.previewURL = projectManager.inspectorURL.URLByAppendingPathComponent("index.html")
                        }
                        else {
                            viewController.previewURL = projectManager.inspectorURL
                        }
                    
                    }
                }
                
                
                
            case "archive":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ArchiveViewController
                viewController.projectManager = projectManager
                
            case "Pulse":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ServersViewController
                viewController.projectManager = projectManager
                
            case "history":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! HistoryViewController
                viewController.projectManager = projectManager
               
            case "moveFile":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! FileMoverViewController
                viewController.fileUrl = projectManager.deleteURL
                viewController.delegate = self
                
            default:
                break
            }
        
        }
        
    }
}
