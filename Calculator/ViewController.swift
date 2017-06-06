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
        
        let evaluation = brain.evaluate()
        
        if let result = evaluation.result {
            if result.truncatingRemainder(dividingBy: 1) == 0{
                display.text = String(Int(result))
            } else {
                displayValue = result
            }
        }
        
        // set the operations display
        if evaluation.isPending {
            operationsDisplay.text = brain.evaluate().description + " ..."
        } else if !evaluation.description.isEmpty {
            operationsDisplay.text = brain.evaluate().description + " ="
        } else {
            operationsDisplay.text = brain.evaluate().description
        }
    }
}

