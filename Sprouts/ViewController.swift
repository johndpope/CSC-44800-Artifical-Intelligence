//
//  ViewController.swift
//  Sprouts
//
//  Created by James Kasakyan on 7/21/15.
//  Copyright © 2015 James Kasakyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var MachineMachineButton: UIButton!
    @IBOutlet weak var HumanMachineButton: UIButton!
    
    var gameMode: String = ""

    @IBAction func MMButtonPressed(sender: AnyObject) {
        gameMode = "Machine-Machine"
    }
    
    @IBAction func HMButtonPressed(sender: AnyObject) {
        gameMode = "Human-Machine"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameViewController: GameViewController = segue.destinationViewController as! GameViewController
        gameViewController.gameMode = self.gameMode
    
    }


}

