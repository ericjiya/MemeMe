//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by jiya on 1/9/16.
//  Copyright © 2016 jiya. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
        
        self.imageView!.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
}
