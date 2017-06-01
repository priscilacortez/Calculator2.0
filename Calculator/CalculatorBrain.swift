//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Priscila Cortez on 5/23/17.
//  Copyright © 2017 Priscila Cortez. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: (value: Double, text: String)?
    private var pendingAccumulator: (value: Double, text: String)?
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var allOperationsMade = ""
    private var temporaryOperationMade = ""
    private var constantToWrite = ""
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    private var operations : Dictionary<String, Operation> = [
        "π"     : Operation.constant(Double.pi),
        "e"     : Operation.constant(M_E),
        "√"     : Operation.unaryOperation(sqrt),
        "cos"   : Operation.unaryOperation(cos),
        "sin"   : Operation.unaryOperation(sin),
        "±"     : Operation.unaryOperation({ -$0 }),
        "1/x"   : Operation.unaryOperation({ 1/$0 }),
        "x²"    : Operation.unaryOperation({ $0 * $0 }),
        "×"     : Operation.binaryOperation({ $0 * $1 }),
        "÷"     : Operation.binaryOperation({ $0 / $1 }),
        "+"     : Operation.binaryOperation({ $0 + $1 }),
        "-"     : Operation.binaryOperation({ $0 - $1 }),
        "="     : Operation.equals,
        "C"     : Operation.clear
    ]
    
    private var complexWrittenUnaryOperations : Dictionary<String, (String) -> String> = [
        "1/x"   : {"1/(\($0))"},
        "x²"    : {"(\($0))²"},
    ]
    
    mutating func performOperation(_ symbol: String){
        
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                accumulator = (value, "\(symbol)")
            
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = (function(accumulator!.value), applyUnaryOperation(with: symbol, on: accumulator!.text))
                }
            
            case .binaryOperation(let function):
                if accumulator != nil {
                    accumulator!.text += " \(symbol) "
                    
                    // perform binary operation with current accumulater if we already had one pending
                    if pendingBinaryOperation != nil {
                        performPendingBinaryOperation()
                    } 
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!.value)
                    pendingAccumulator = accumulator
                    accumulator = nil
                }
            
            case .equals:
                performPendingBinaryOperation()
                
            case .clear:
                pendingBinaryOperation = nil
                accumulator = nil
                pendingAccumulator = nil
            }
        }
    }
    
    mutating func setOperand(_ operand: Double){
        // sets accumulator and removes trailing .0 if an integer to the text
        accumulator = (operand, operand.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(operand)) : String(operand))
    }
    
    mutating func setOperand(variable named: String){
        accumulator = (0, named)
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String){
        
    }
    
    var result: Double? {
        get {
            return accumulator?.value
        }
    }
    
    var pendingResult: Bool {
        get {
            if pendingBinaryOperation != nil {
                return true
            }
            return false
        }
    }
    
    var description: String {
        get {
            guard pendingAccumulator != nil || accumulator != nil else {
                return ""
            }
            
            return pendingAccumulator?.text ?? accumulator!.text
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private mutating func applyUnaryOperation(with symbol: String, on operationsMade: String ) -> String {
        if let writeComplexOperation = complexWrittenUnaryOperations[symbol]{
            return writeComplexOperation(operationsMade)
            
        }
        return "\(symbol) (\(operationsMade)) "
    }
    
    private mutating func performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator!.text = "\(pendingAccumulator!.text) \(accumulator!.text) "
            accumulator!.value = pendingBinaryOperation!.perform(with: accumulator!.value)
            pendingBinaryOperation = nil
            pendingAccumulator = nil
        }
    }
}
