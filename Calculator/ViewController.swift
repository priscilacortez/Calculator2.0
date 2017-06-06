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
    @IBOutlet weak var variableDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var variables: [String: Double]?
    
    private var brain = CalculatorBrain()
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
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
    
    @IBAction func addVariable(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        brain.setOperand(variable: sender.currentTitle!)
        
        showResult()
    }
    
    @IBAction func evaluateVariable(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let variable = "M"
        let value = displayValue
        
        variableDisplay.text = "\(variable) = \(value)"
        
        if variables != nil {
            variables![variable] = value
        } else {
            variables = [variable: value]
        }
        
        showResult()
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            
            if mathematicalSymbol == "C"{
                display.text = "0"
                variables = nil
                variableDisplay.text = ""
            }
        }
        
        showResult()
    }
    
    private func showResult(){
        let evaluation = brain.evaluate(using: variables)
        
        if let result = evaluation.result {
            if result.truncatingRemainder(dividingBy: 1) == 0{
                display.text = String(Int(result))
            } else {
                displayValue = result
            }
        }
        
        // set the operations display
        if evaluation.isPending {
            operationsDisplay.text = evaluation.description + " ..."
        } else if !evaluation.description.isEmpty {
            operationsDisplay.text = evaluation.description + " ="
        } else {
            operationsDisplay.text = evaluation.description
        }
    }
}

