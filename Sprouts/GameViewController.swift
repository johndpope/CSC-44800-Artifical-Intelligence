//
//  GameViewController.swift
//  Sprouts
//
//  Created by James Kasakyan on 7/21/15.
//  Copyright © 2015 James Kasakyan. All rights reserved.
//

import Foundation
import UIKit
import Darwin


class SproutsNode {
    
    var image: UIImage
    var adjacencyArray: [SproutsNode?]
    let isLeaf: Bool
    var value: Int?
    var type: String
    
    init (isLeaf: Bool, image: UIImage, type: String)
    {
        self.image = image
        self.isLeaf = isLeaf
        self.adjacencyArray = [SproutsNode?](count: 4, repeatedValue: nil)
        self.type = type
        if (self.type == "min")
        {
            self.value = 2
        }
        else
        {
            self.value = -1
        }
    }
    
    func addToAdjacency(node: SproutsNode, atIndex: Int)
    {
        self.adjacencyArray.insert(node, atIndex: atIndex)
    }
    
    
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var currentStateImage: UIImageView!
    @IBOutlet weak var gameModeLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var cpuTurnButton: UIButton!
    
    var gameMode: String = ""
    var CPUAlgorithm: String = ""
    var imageArray: [UIImage] = []
    var currentNode: SproutsNode? = nil
    var winAlertController: UIAlertController = UIAlertController()
    var turnAlertController: UIAlertController = UIAlertController()
    var algorithmAlertController: UIAlertController = UIAlertController()
    var maxPlayer: String = ""
    var minPlayer: String = ""
    var geneticAlgorithmTurn = 0
    var solutionString: String = ""
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBAction func buttonOnePressed(sender: AnyObject) {
        resolveTurnLabel()
        self.currentNode = self.currentNode?.adjacencyArray[0]
        resolveImages(self.currentNode!)
        self.checkWinCondition(self.currentNode!)
    }
    
    @IBOutlet weak var buttonTwo: UIButton!
    @IBAction func buttonTwoPressed(sender: AnyObject) {
        resolveTurnLabel()
        self.currentNode = self.currentNode?.adjacencyArray[1]
        resolveImages(self.currentNode!)
        self.checkWinCondition(self.currentNode!)
    }
    
    @IBOutlet weak var buttonThree: UIButton!
    @IBAction func buttonThreePressed(sender: AnyObject) {
        resolveTurnLabel()
        self.currentNode = self.currentNode?.adjacencyArray[2]
        resolveImages(self.currentNode!)
        self.checkWinCondition(self.currentNode!)
    }
    
    @IBOutlet weak var buttonFour: UIButton!
    @IBAction func buttonFourPressed(sender: AnyObject) {
        resolveTurnLabel()
        self.currentNode = self.currentNode?.adjacencyArray[3]
        resolveImages(self.currentNode!)
        self.checkWinCondition(self.currentNode!)
    }
    
    @IBAction func cpuTurnButtonPressed(sender: AnyObject) {
        if (self.turnLabel.text == "CPU 1")
        {
            self.currentNode = self.miniMaxChoice(currentNode!)
        }
        else
        {
            if (self.CPUAlgorithm == "genetic")
            {
                self.currentNode = self.GAChoice(self.currentNode!, turnNum: geneticAlgorithmTurn, solutionString: self.solutionString)
                self.geneticAlgorithmTurn++
            }
            else
            {
                self.currentNode = self.miniMaxChoice(self.currentNode!)
            }
        }
        resolveImages(self.currentNode!)
        resolveTurnLabel()
        self.checkWinCondition(self.currentNode!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.geneticAlgorithmTurn = 0
        imageArray = initializeImageArray()
        currentNode = initializeSproutsNodes()
        self.miniMax(currentNode)
        
        // Initialize the screen for a new game
        self.gameModeLabel.text = "Mode: " + gameMode
        if (self.gameMode == "Human-Machine")
        {
            self.turnLabel.hidden = true
            turnAlertController = UIAlertController(title: nil, message: "Who plays first?" , preferredStyle: .ActionSheet)
            
            let humanAction = UIAlertAction(title: "Human", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.turnLabel.text = "Player 1"
                self.turnLabel.hidden = false
                self.setUpHumanTurn();
                self.maxPlayer = "Player 1"
                self.minPlayer = "CPU"
            })
            turnAlertController.addAction(humanAction)
            
            let CPUAction = UIAlertAction(title: "CPU", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.turnLabel.text = "CPU 1"
                self.turnLabel.hidden = false
                self.setUpCPUTurn()
                self.maxPlayer = "CPU"
                self.minPlayer = "Player 1"
            })
            turnAlertController.addAction(CPUAction)
            self.presentViewController(turnAlertController, animated: true, completion: nil)
        }
        else
        {  // Game mode is Machine-Machine
                self.turnLabel.text = "CPU 1"
                self.maxPlayer = "CPU 1"
                self.minPlayer = "CPU 2"
            
            algorithmAlertController = UIAlertController(title: nil, message: "Which algorithm should CPU 2 use?", preferredStyle: .ActionSheet)
            
            let minimaxAction = UIAlertAction(title: "Minimax", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.CPUAlgorithm = "minimax"
                self.setUpCPUTurn()
            })
            algorithmAlertController.addAction(minimaxAction)
            
            let geneticAlgorithmAction = UIAlertAction(title: "Genetic Algorithm", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.CPUAlgorithm = "genetic"
                self.setUpCPUTurn()
                self.solutionString = self.geneticAlgorithm(self.currentNode!)
                print("Solution string is \(self.solutionString)")
            })
            algorithmAlertController.addAction(geneticAlgorithmAction)
            self.presentViewController(algorithmAlertController, animated: true, completion: nil)
        }
        
        resolveImages(currentNode!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resolveTurnLabel()
    {
        switch gameMode {
        case "Human-Machine":
            if (self.turnLabel.text == "Player 1")
            { self.turnLabel.text = "CPU"; self.setUpCPUTurn()}
            else {self.turnLabel.text = "Player 1"; self.setUpHumanTurn()}
            
        case "Machine-Machine":
            if (self.turnLabel.text == "CPU 1")
            {self.turnLabel.text = "CPU 2"; self.setUpCPUTurn()}
            else {self.turnLabel.text = "CPU 1"; self.setUpCPUTurn()}
            
        default:
            print("Invalid value for gameMode variable")
        }

    }
    
    func initializeImageArray() -> [UIImage]
    {
        var imageArray: [UIImage] = []
        for var i = 0; i < 46; i++
        {
            imageArray.append(UIImage(named: "sprouts\(i).jpg")!)
        }
        return imageArray
    }
    
    func initializeSproutsNodes() -> SproutsNode
    {
        let node0 = SproutsNode(isLeaf: false, image: imageArray[0], type: "max")
        let node1 = SproutsNode(isLeaf: false, image: imageArray[1], type: "min")
        let node2 = SproutsNode(isLeaf: false, image: imageArray[2], type: "min")
        let node3 = SproutsNode(isLeaf: false, image: imageArray[3], type: "max")
        let node4 = SproutsNode(isLeaf: false, image: imageArray[4], type: "max")
        let node5 = SproutsNode(isLeaf: false, image: imageArray[5], type: "max")
        let node6 = SproutsNode(isLeaf: false, image: imageArray[6], type: "max")
        let node7 = SproutsNode(isLeaf: false, image: imageArray[7], type: "max")
        let node8 = SproutsNode(isLeaf: false, image: imageArray[8], type: "max")
        let node9 = SproutsNode(isLeaf: false, image: imageArray[9], type: "min")
        let node10 = SproutsNode(isLeaf: false, image: imageArray[10], type: "min")
        let node11 = SproutsNode(isLeaf: false, image: imageArray[11], type: "min")
        let node12 = SproutsNode(isLeaf: false, image: imageArray[12], type: "min")
        let node13 = SproutsNode(isLeaf: false, image: imageArray[13], type: "min")
        let node14 = SproutsNode(isLeaf: false, image: imageArray[14], type: "min")
        let node15 = SproutsNode(isLeaf: false, image: imageArray[15], type: "min")
        let node16 = SproutsNode(isLeaf: false, image: imageArray[16], type: "min")
        let node17 = SproutsNode(isLeaf: false, image: imageArray[17], type: "min")
        let node18 = SproutsNode(isLeaf: false, image: imageArray[18], type: "max")
        let node19 = SproutsNode(isLeaf: false, image: imageArray[19], type: "max")
        let node20 = SproutsNode(isLeaf: false, image: imageArray[20], type: "max")
        let node21 = SproutsNode(isLeaf: true, image: imageArray[21], type: "max")
        let node22 = SproutsNode(isLeaf: true, image: imageArray[22], type: "max")
        let node23 = SproutsNode(isLeaf: false, image: imageArray[23], type: "max")
        let node24 = SproutsNode(isLeaf: false, image: imageArray[24], type: "max")
        let node25 = SproutsNode(isLeaf: false, image: imageArray[25], type: "max")
        let node26 = SproutsNode(isLeaf: false, image: imageArray[26],type: "max")
        let node27 = SproutsNode(isLeaf: false, image: imageArray[27], type: "max")
        let node28 = SproutsNode(isLeaf: false, image: imageArray[28], type: "max")
        let node29 = SproutsNode(isLeaf: true, image: imageArray[29], type: "max")
        let node30 = SproutsNode(isLeaf: false, image: imageArray[30], type: "max")
        let node31 = SproutsNode(isLeaf: false, image: imageArray[31], type: "max")
        let node32 = SproutsNode(isLeaf: true, image: imageArray[32], type: "max")
        let node33 = SproutsNode(isLeaf: true, image: imageArray[33], type: "max")
        let node34 = SproutsNode(isLeaf: true, image: imageArray[34], type: "max")
        let node35 = SproutsNode(isLeaf: true, image: imageArray[35], type: "min")
        let node36 = SproutsNode(isLeaf: true, image: imageArray[36], type: "min")
        let node37 = SproutsNode(isLeaf: true, image: imageArray[37], type: "min")
        let node38 = SproutsNode(isLeaf: true, image: imageArray[38], type: "min")
        let node39 = SproutsNode(isLeaf: true, image: imageArray[39], type: "min")
        let node40 = SproutsNode(isLeaf: true, image: imageArray[40], type: "min")
        let node41 = SproutsNode(isLeaf: true, image: imageArray[41], type: "min")
        let node42 = SproutsNode(isLeaf: true, image: imageArray[42], type: "min")
        let node43 = SproutsNode(isLeaf: true, image: imageArray[43], type: "min")
        let node44 = SproutsNode(isLeaf: true, image: imageArray[44], type: "min")
        let node45 = SproutsNode(isLeaf: true, image: imageArray[45], type: "min")
        
        node0.adjacencyArray[0] = node1
        node0.adjacencyArray[1] = node2
        
        node1.adjacencyArray[0] = node3
        node1.adjacencyArray[1] = node4
        node1.adjacencyArray[2] = node5
        node1.adjacencyArray[3] = node6
        
        node2.adjacencyArray[0] = node6
        node2.adjacencyArray[1] = node7
        node2.adjacencyArray[2] = node8
        
        node3.adjacencyArray[0] = node9
        node3.adjacencyArray[1] = node10
        
        node4.adjacencyArray[0] = node10
        node4.adjacencyArray[1] = node11
        node4.adjacencyArray[2] = node12
        
        node5.adjacencyArray[0] = node11
    
        node6.adjacencyArray[0] = node12
        node6.adjacencyArray[1] = node13
        node6.adjacencyArray[2] = node14
        node6.adjacencyArray[3] = node15
        
        node7.adjacencyArray[0] = node15
        node7.adjacencyArray[1] = node16
        
        node8.adjacencyArray[0] = node16
        node8.adjacencyArray[1] = node17
        
        node9.adjacencyArray[0] = node18
        node9.adjacencyArray[1] = node19
        
        node10.adjacencyArray[0] = node19
        node10.adjacencyArray[1] = node20
        node10.adjacencyArray[2] = node21
        
        node11.adjacencyArray[0] = node21
        node11.adjacencyArray[1] = node22
    
        node12.adjacencyArray[0] = node23
        node12.adjacencyArray[1] = node24
        
        node13.adjacencyArray[0] = node24
        node13.adjacencyArray[1] = node25
        
        node14.adjacencyArray[0] = node26
        node14.adjacencyArray[1] = node27
    
        node15.adjacencyArray[0] = node27
        node15.adjacencyArray[1] = node28
        node15.adjacencyArray[2] = node29
        
        node16.adjacencyArray[0] = node30
        node16.adjacencyArray[1] = node31
        node16.adjacencyArray[2] = node32
        
        node17.adjacencyArray[0] = node33
        node17.adjacencyArray[1] = node34
        
        node18.adjacencyArray[0] = node35
        
        node19.adjacencyArray[0] = node36
        
        node20.adjacencyArray[0] = node37
        
        node23.adjacencyArray[0] = node38
        
        node24.adjacencyArray[0] = node39
        
        node25.adjacencyArray[0] = node40
        
        node26.adjacencyArray[0] = node41
        
        node27.adjacencyArray[0] = node42
        
        node28.adjacencyArray[0] = node43
        
        node30.adjacencyArray[0] = node44
        
        node31.adjacencyArray[0] = node45
        
        return node0
    }
    
    func resolveImages(currentNode: SproutsNode)
    {
        self.currentStateImage.image = currentNode.image
        if (currentNode.adjacencyArray[0] != nil)
        {
            self.buttonOne.hidden = false
            self.buttonOne.setImage(currentNode.adjacencyArray[0]?.image, forState: UIControlState.Normal)
        }
        else {buttonOne.hidden = true; buttonTwo.hidden = true; buttonThree.hidden = true; buttonFour.hidden = true; return}
        
        if (currentNode.adjacencyArray[1] != nil)
        {
            self.buttonTwo.hidden = false
            self.buttonTwo.setImage(currentNode.adjacencyArray[1]?.image, forState: UIControlState.Normal)
        }
        else {buttonTwo.hidden = true; buttonThree.hidden = true; buttonFour.hidden = true; return}
        
        if (currentNode.adjacencyArray[2] != nil)
        {
            self.buttonThree.hidden = false
            self.buttonThree.setImage(currentNode.adjacencyArray[2]?.image, forState: UIControlState.Normal)
        }
        else {buttonThree.hidden = true; buttonFour.hidden = true; return}
        
        if (currentNode.adjacencyArray[3] != nil)
        {
            self.buttonFour.hidden = false
            self.buttonFour.setImage(currentNode.adjacencyArray[3]?.image, forState: UIControlState.Normal)
        }
        else {buttonFour.hidden = true; return}
    }
    
    func checkWinCondition (currentNode: SproutsNode) -> Bool
    {
        if currentNode.isLeaf == false
        {
            return false
        }
        
        else
        {
            if currentNode.type == "max"
            {
                minVictory()
            }
            
            else
            {
                maxVictory()
            }
        }
        return true
    }
    
    func minVictory()
    {
//        if (self.gameMode == "Machine-Machine")
//        {
//            winAlertController = UIAlertController(title: nil, message: "CPU 2 WINS!" , preferredStyle: .ActionSheet)
//        }
//        
//        else if (self.gameMode == "Human-Machine")
//        {
//            winAlertController = UIAlertController(title: nil, message: "CPU WINS!" , preferredStyle: .ActionSheet)
//        }
        
        winAlertController = UIAlertController(title: nil, message: "\(self.minPlayer) WINS!", preferredStyle: .ActionSheet)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.CPUAlgorithm = ""
            self.performSegueWithIdentifier("gameEnd", sender: self)
        })
        
        winAlertController.addAction(dismissAction)
        
        self.presentViewController(winAlertController, animated: true, completion: nil)
    }
    
    func maxVictory()
    {
        winAlertController = UIAlertController(title: nil, message: "\(self.maxPlayer) WINS!", preferredStyle: .ActionSheet)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.CPUAlgorithm = ""
            self.performSegueWithIdentifier("gameEnd", sender: self)
        })
        
        winAlertController.addAction(dismissAction)
        
        self.presentViewController(winAlertController, animated: true, completion: nil)
    }
    
    func setUpCPUTurn()
    {
        self.cpuTurnButton.hidden = false
        if (self.CPUAlgorithm == "genetic" && self.turnLabel.text == "CPU 2")
        {
            self.cpuTurnButton.setTitle("Perform GA turn", forState: UIControlState.Normal)
        }
        else
        {
            self.cpuTurnButton.setTitle("Perform minimax turn", forState: UIControlState.Normal)
        }
        self.buttonOne.userInteractionEnabled = false
        self.buttonTwo.userInteractionEnabled = false
        self.buttonThree.userInteractionEnabled = false
        self.buttonFour.userInteractionEnabled = false
    }
    
    func setUpHumanTurn()
    {
        self.cpuTurnButton.hidden = true
        self.buttonOne.userInteractionEnabled = true
        self.buttonTwo.userInteractionEnabled = true
        self.buttonThree.userInteractionEnabled = true
        self.buttonFour.userInteractionEnabled = true
    }
    
    func miniMax(node: SproutsNode?)
    {
        if node?.isLeaf == true
        {
            if (node?.type == "max")
            {
                node?.value = 0     // Ended on Max node, value of 0 for Max player
            }
            if (node?.type == "min")
            {
                node?.value = 1     // Ended on Min node, value of 1 for Min player
            }
            return
        }
        
        for childNode in node!.adjacencyArray
        {
            if (childNode != nil)
            {
                miniMax(childNode)
            }
        }
        
        for childNode in node!.adjacencyArray
        {
            if (childNode != nil)
            {
                if (node?.type == "max" && childNode?.value > node?.value)
                {
                    node?.value = childNode?.value
                }
                else if (node?.type == "min" && childNode?.value < node?.value)
                {
                    node?.value = childNode?.value
                }
            }
        }
    }
    
    
    func miniMaxChoice (node: SproutsNode) -> SproutsNode
    {
        var bestNode: SproutsNode? = nil
        if (node.type == "max")
        {
            for childNode in node.adjacencyArray
            {
                if (childNode != nil)
                {
                    if (childNode?.value == 1)
                    {
                        bestNode = childNode!
                        return bestNode!
                    }
                }
            }
            bestNode = self.randomChoice(node)
            return bestNode!
        }
        
        if (node.type == "min")
        {
            for childNode in node.adjacencyArray
            {
                if (childNode != nil)
                {
                    if (childNode?.value == 0)
                    {
                        bestNode = childNode!
                        return bestNode!
                    }
                }
            }
            bestNode = self.randomChoice(node)
            return bestNode!

        }
        print("Control should not reach here")
        return bestNode!
    }
    
    func randomChoice (node: SproutsNode) -> SproutsNode
    {
        var validIndex: Int = -1
        for childNode in node.adjacencyArray
        {
            if childNode != nil
            {
                validIndex++
            }
        }
        
        if validIndex == 0
        {
            return node.adjacencyArray[0]!
        }
       
        let randomIndex = Int(arc4random_uniform(UInt32(validIndex+1)))
        return node.adjacencyArray[randomIndex]!
    }
    
    func geneticAlgorithm (node: SproutsNode) -> String
    {
//         String encoding: Regardless of whether the game finishes in 3n-1 moves (n = 2, 3n-1 = 5) or 2n moves (n = 2, 2n = 4),
//                          the total number of game decisions for player 2 is 2. At most, a game state has 4 valid plays.
//                          N unique states can be represent by Log2(N) bits; N = 4, so each play needs to be encoded with
//                          Log2(4) = 2 bits. Thus a complete solution requires a string of length:
//                           2 (bits to encode one move) * 2 (number of game decisions) = 4.
//        
//                          00 = node.adjacencyArray[0]
//                          01 = node.adjacencyArray[1]
//                          10 = node.adjacencyArray[2]
//                          11 = node.adjacencyArray[3]
//        
//                          Since the number of decisions possible at a certain game state for player 2 can range from 2-4,
//                          provisions must be made to prevent the production of invalid solutions that would result
//                          in attempting to make an invalid play. For example, a random initial solution might be of the form 1111.
//                          However, on the second turn of player 2 the maximum number of decisions to choose from is three, and a
//                          solution string of 1111 corresponds to choosing the fourth possible option twice. To reconcile this and
//                          similar conditions from occuring, whenever a string corresponds to an invalid move, the next highest
//                          possible choice will be made. Thus a solution string of 1111 will be treated like a string of 1110 if
//                          there are 3 possible decisions from the second game state, 1101 if there are 2 possible decisions, and
//                          1100 if there is only one possible decision from the second game state.
//        
//                          Strategy:
//                          As the second player in a two node game of sprouts, a winning strategy is available that guarantees
//                          victory. It involves, whenever possible, restricting the number of playable nodes for the opponent
//                          Usually this entails connecting two vertices of degree two (thus making them both degree 3 and "dead")
//                          such that the new vertex placed on this new edge is unable to connect to any remaining edge of degree 2
//                          (usually because it inside a "loop" whose edges act as a sort of barricade). In the game tree used in
//                          this program, the third choice at any game state (if no third choice exists, the next highest choice)
//                          corresponds to a move employing this strategy. This strategy guarantees a win against an opponent.
//        
//                          Fitness Function f(s)
//                          Since sprouts is a game of perfect information, the fitness function is relatively straightforward. A
//                          candidate solution string s simulates a match against a minimax opponent. If the solution results in a
//                          win for the player, its fitness is increased by 1. However since the minimax opponent does not always
//                          make the same play (if all choices are equally bad, he will make a random choice), a win for the player
//                          does not guarantee that this candidate string s corresponds to a string representing the strategy above,
//                          which is guaranteed to win regardless of the decisions of the opponent. Thus, to reduce the possibility
//                          of a random chance solution happening to win, the fitness function simulates 25 matches, adding a
//                          fitness of 1 for each victory. Probabilistically, when a candidate solution string has a fitness of 25,
//                          it corresponds to this winning strategy, and further generation can be stopped.
        
//         Produce initial population of candidate solution strings randomly. Population size = 4
        
        var candidateStrings: [String] = []
        var isDuplicate: Bool
        var stringArray: [String] = []
        var fitnessArray: [Int] = []
        while (candidateStrings.count != 4)
        {
            var solutionString: String = ""
            isDuplicate = false
            for var i = 0; i < 2; i++
            {
                
                let randomNum = Int(arc4random_uniform(UInt32(4))) + 1   // Number between 1 and 4
                if (randomNum == 1)
                {
                    solutionString += "00"
                }
                else if (randomNum == 2)
                {
                    solutionString += "01"
                }
                else if (randomNum == 3)
                {
                    solutionString += "10"
                }
                else
                {
                    solutionString += "11"
                }
            }
            if (candidateStrings.count > 0)
            {
                for string in candidateStrings
                {
                    if string == solutionString
                    {
                        isDuplicate = true
                    }
                }
                if (isDuplicate == false)
                {
                    candidateStrings.append(solutionString)
                }
            }
            else
            {
                candidateStrings.append(solutionString)
            }
        }
        // Calculate fitness of original population
        stringArray = candidateStrings
        fitnessArray = [evaluateFitness(stringArray[0], node: node), evaluateFitness(stringArray[1], node: node), evaluateFitness(stringArray[2], node: node), evaluateFitness(stringArray[3], node: node)]
        
        var mostFitString = ""
        var highestFitness = -1
        for var i = 0; i < 4; i++
        {
            if fitnessArray[i] > highestFitness
            {
                highestFitness = fitnessArray[i]
                mostFitString = stringArray[i]
            }
        }
        
        if (highestFitness == 25)   // Best possible solution was randomly generated
        {
            print ("Found most fit string \(mostFitString) in original population")
            return mostFitString
        }
        
        // No ideal string found in initial population. Allow generation
        let generations = 50
        for var i = 0; i < generations; i++
        {
            let parentPool = selectMates(stringArray, fitnessArray: fitnessArray)
            let postCrossover = performCrossover(parentPool)
            var finalPopulation: [String] = []
            for string1 in postCrossover
            {
                finalPopulation.append(performMutation(string1))
            }
        stringArray = finalPopulation
        fitnessArray = [evaluateFitness(stringArray[0], node: node), evaluateFitness(stringArray[1], node: node), evaluateFitness(stringArray[2], node: node), evaluateFitness(stringArray[3], node: node)]
        
            
        highestFitness = -1
        mostFitString = ""
        for var i = 0; i < 4; i++
        {
            if fitnessArray[i] > highestFitness
            {
                highestFitness = fitnessArray[i]
                mostFitString = stringArray[i]
            }

        }
            if (highestFitness == 25)
            {
                print ("Found most fit string \(mostFitString) in generation \(i)")
                return mostFitString
            }
            print("Best string for generation \(i): \(mostFitString) with fitness \(highestFitness)")
        }
        print("After \(generations) generations, the most fit string is \(mostFitString)")
        return mostFitString
    }
    
    func evaluateFitness(candidateString: String, node: SproutsNode) -> Int
    {
        var fitness = 0
        for var i = 0; i < 25; i++
        {
            var minTurn = 0
            var currentNode = node
            while (currentNode.isLeaf == false)
            {
                if (currentNode.type == "max")
                {
                    currentNode = self.miniMaxChoice(currentNode)
                }
                else
                {
                    if (minTurn == 0)
                    {
                        let index0 = candidateString.startIndex
                        let index1 = advance(candidateString.startIndex, 1)
                        if (candidateString[index0] == "0" && candidateString[index1] == "0")
                        {
                            currentNode = attemptMove(currentNode,index: 0)
                        }
                        else if (candidateString[index0] == "0" && candidateString[index1] == "1")
                        {
                            currentNode = attemptMove(currentNode, index: 1)
                        }
                        else if (candidateString[index0] == "1" && candidateString[index1] == "0")
                        {
                            currentNode = attemptMove(currentNode, index: 2)
                        }
                        else
                        {
                            currentNode = attemptMove(currentNode, index: 3)
                        }
                        minTurn++
                    }
                        
                    else
                    {
                        let index2 = advance(candidateString.startIndex, 2)
                        let index3 = advance(candidateString.startIndex, 3)
                        if (candidateString[index2] == "0" && candidateString[index3] == "0")
                        {
                            currentNode = attemptMove(currentNode,index: 0)
                        }
                        else if (candidateString[index2] == "0" && candidateString[index3] == "1")
                        {
                            currentNode = attemptMove(currentNode, index: 1)
                        }
                        else if (candidateString[index2] == "1" && candidateString[index3] == "0")
                        {
                            currentNode = attemptMove(currentNode, index: 2)
                        }
                        else
                        {
                            currentNode = attemptMove(currentNode, index: 3)
                        }

                    }
                }
            }
            // currentNode is now a leaf, game is over, see who won
            if (currentNode.type == "max")
            {
                fitness += 1
            }
        }
        return fitness
    }
    
    func attemptMove (node: SproutsNode, index: Int) -> SproutsNode
    {
        var possibleIndex = index
        if (possibleIndex == 0)
        {
            return node.adjacencyArray[0]!
        }
        
        while (possibleIndex != 0)
        {
            if (node.adjacencyArray[possibleIndex] != nil)
            {
                return node.adjacencyArray[possibleIndex]!
            }
            possibleIndex--
        }
        return node.adjacencyArray[0]!

    }
    
    func selectMates (stringArray: [String], fitnessArray: [Int]) -> [String]
    {
        var totalFitness = 0
        var probability = 0.0
        var selectedMates: [String] = []
        for var i = 0; i < 4; i++
        {
            totalFitness += fitnessArray[i]
        }
        while (selectedMates.count < 4)
        {
            for var j = 0; j < 4; j++
            {
                let fitness = fitnessArray[j]
                if (totalFitness == 0)
                {
                    probability = 0.25
                }
                else
                {
                    probability = Double(fitness) / Double(totalFitness)
                }
                let randomNum = Double(arc4random()) / Double(UINT32_MAX)
                if (probability > randomNum)
                {
                    selectedMates.append(stringArray[j])
                }
            }
        }
        return selectedMates
    }
    
    func performCrossover (parentPool: [String]) -> [String]
    {
        // Select mating partner
        let selectedMateIndex = Int(arc4random_uniform(3)) + 1
        
        // Select crossover point
        let firstArray = crossoverHelper(parentPool[0], string2: parentPool[selectedMateIndex])
        var secondArray: [String] = []
        
        //Crossover last two eligible strings
        if (selectedMateIndex == 1)
        {
            //Crossover 2 and 3
           secondArray = crossoverHelper(parentPool[2], string2: parentPool[3])
        }
        else if (selectedMateIndex == 2)
        {
            //Crossover 1 and 3
            secondArray = crossoverHelper(parentPool[1], string2: parentPool[3])
        }
        else
        {
            //Crossover 1 and 2
            secondArray = crossoverHelper(parentPool[1], string2: parentPool[2])
        }
        return (firstArray + secondArray)
    }
    
    func crossoverHelper(string1: String, string2: String) -> [String]
    {
        var crossedArray: [String] = []
        let crossoverPoint = Int(arc4random_uniform(3)) + 1
        var index = advance(string1.startIndex, crossoverPoint)
        var newstring1 = ""
        var newstring2 = ""
        var beforeCrossIndex = string1.startIndex
        while (beforeCrossIndex != index)
        {
            newstring1.append(string1[beforeCrossIndex])
            newstring2.append(string2[beforeCrossIndex])
            beforeCrossIndex = beforeCrossIndex.successor()
        }
        while (index != string1.endIndex)
        {
            let temp = string1[index]
            newstring1.append(string2[index])
            newstring2.append(temp)
            index = index.successor()
        }
//        let temp = string1[string1.endIndex]
//        newstring1.append(string2[string1.endIndex])
//        newstring2.append(temp)
        
        crossedArray.append(newstring1)
        crossedArray.append(newstring2)
        return crossedArray
    }
    
    func performMutation(string1: String) -> String
    {
        var newString = ""
        var index = string1.startIndex
        while (index != string1.endIndex)
        {
            let randomNum = Double(arc4random()) / Double(UINT32_MAX)
            if (randomNum <= 0.05)
            {
                if (string1[index] == "0")
                {
                    newString += "1"
                }
                else
                {
                    newString += "0"
                }
            }
            else
            {
                newString.append(string1[index])
            }
            index = index.successor()
        }
        
        return newString
    }
    
    func GAChoice(node: SproutsNode, turnNum: Int, solutionString: String) -> SproutsNode
    {
        if (turnNum == 0)
        {
            let index0 = solutionString.startIndex
            let index1 = advance(solutionString.startIndex, 1)
            if (solutionString[index0] == "0" && solutionString[index1] == "0")
            {
                return attemptMove(node,index: 0)
            }
            else if (solutionString[index0] == "0" && solutionString[index1] == "1")
            {
                return attemptMove(node, index: 1)
            }
            else if (solutionString[index0] == "1" && solutionString[index1] == "0")
            {
                return attemptMove(node, index: 2)
            }
            else
            {
                return attemptMove(node, index: 3)
            }
        }
        else
        {
            let index2 = advance(solutionString.startIndex, 2)
            let index3 = advance(solutionString.startIndex, 3)
            if (solutionString[index2] == "0" && solutionString[index3] == "0")
            {
                return attemptMove(node,index: 0)
            }
            else if (solutionString[index2] == "0" && solutionString[index3] == "1")
            {
                return attemptMove(node, index: 1)
            }
            else if (solutionString[index2] == "1" && solutionString[index3] == "0")
            {
                return attemptMove(node, index: 2)
            }
            else
            {
                return attemptMove(node, index: 3)
            }
        }

    }
    
}

