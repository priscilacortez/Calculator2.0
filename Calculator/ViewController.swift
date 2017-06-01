//
//  ViewController.swift
//  Calculator
//
//  Created by Priscila Cortez on 5/16/17.
//  Copyright © 2017 Priscila Cortez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var operationsDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            
            if digit == "." && textCurrentlyInDisplay.contains(digit) == true {
                return
            }
            
            display.text = textCurrentlyInDisplay + digit
   
        } else {
            // if digit is a dot, then do "0." if not then just the digit
            display.text = (digit == ".") ? "0" + digit : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            
            if mathematicalSymbol == "C"{
                display.text = "0"
            }
        }
        
        if let result = brain.result {
            if result.truncatingRemainder(dividingBy: 1) == 0{
                display.text = String(Int(result))
            } else {
                displayValue = result
            }
        }
        
        // set the operations display
        if brain.pendingResult {
            operationsDisplay.text = brain.description + " ..."
        } else if !brain.description.isEmpty {
            operationsDisplay.text = brain.description + " ="
        } else {
            operationsDisplay.text = brain.description
        }
    }
}

