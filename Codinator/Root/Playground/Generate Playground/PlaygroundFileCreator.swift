//
//  PlaygroundFileCreator.swift
//  Codinator
//
//  Created by Vladimir Danila on 26/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class PlaygroundFileCreator: NSObject {

    /// Returns the file url of a Playground with a name
    class func fileUrlForPlaygroundWithName(_ fileName: String) -> URL {
        
        let fileName = fileName + ".cnPlay"
        
        let rootUrl = URL(fileURLWithPath: AppDelegate.storagePath())
        let playgroundPaths = try! rootUrl.appendingPathComponent("Playground", isDirectory: true)
        let fileUrl = try! playgroundPaths.appendingPathComponent(fileName, isDirectory: false)
        
        return fileUrl
    }
    
    
    class func generatePlaygroundFileWithName(_ fileName: String) -> PlaygroundDocument {
        
        // Get URL
        let fileUrl = PlaygroundFileCreator.fileUrlForPlaygroundWithName(fileName)
        
        // Create document
        let document = PlaygroundDocument(fileURL: fileUrl)
        document.save(to: fileUrl, for: .forCreating, completionHandler: nil)
   
        // Neuron file
        let neuronFile =
            "START \n" +
            "    HEAD() \n" +
            "        TITLE(\"" + fileName +  "\")TITLE \n" +
            "        VIEWPORT(content: \"width=device-width\", initialScale: 1)\n" +
            "        DESCRIPTION(\"A simple webpage written in Neuron\")         \n" +
            "        AUTHOR(\"YOUR NAME\")    \n" +
            "        IMPORT(CSS)   \n" +
            "        IMPORT(JS)   \n" +
            "    ()HEAD \n" +
            "    BODY() \n" +
            "    \n" +
            "        H1(\"" + "\")H1 \n" +
            "        P(\"Hello World\")P \n" +
            "        \n" +
            "    ()BODY \n" +
            "END"
        
        
        //CSS file
        let cssFile = FileTemplates.cssTemplateFile()
        
        
        // JS file
        let jsFile = FileTemplates.jsTemplateFile()
        
        document.contents.add(neuronFile)
        document.contents.add(cssFile!)
        document.contents.add(jsFile!)
//        document.setFile(.Neuron, toFile: neuronFile)
//        document.setFile(.JS, toFile: jsFile)
//        document.setFile(.CSS, toFile: cssFile)
        
        return document
    }
    
    
}
