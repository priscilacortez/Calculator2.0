//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Priscila Cortez on 5/23/17.
//  Copyright © 2017 Priscila Cortez. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private var sequenceOfOperations = [OperationKeys]()
    
    private enum OperationKeys {
        case number(Double)
        case variable(String)
        case symbol(String)
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
        case undo
    }
    
    private var operations : Dictionary<String, Operation> = [
        "π"     : Operation.constant(Double.pi),
        "e"     : Operation.constant(M_E),
        "√"     : Operation.unaryOperation(sqrt),
        "cos"   : Operation.unaryOperation(cos),
        "sin"   : Operation.unaryOperation(sin),
        "±"     : Operation.unaryOperation({ -$0 }),
        "x⁻¹"   : Operation.unaryOperation({ pow($0, -1) }),
        "x⁻²"   : Operation.unaryOperation({ pow($0, -2) }),
        "x²"    : Operation.unaryOperation({ pow($0, 2) }),
        "x³"    : Operation.unaryOperation({ pow($0, 3) }),
        "×"     : Operation.binaryOperation({ $0 * $1 }),
        "÷"     : Operation.binaryOperation({ $0 / $1 }),
        "+"     : Operation.binaryOperation({ $0 + $1 }),
        "-"     : Operation.binaryOperation({ $0 - $1 }),
        "="     : Operation.equals,
        "C"     : Operation.clear,
        "←"     : Operation.undo
    ]
    
    private var complexWrittenUnaryOperations : Dictionary<String, (String) -> String> = [
        "x⁻¹"   : {"(\($0))⁻¹"},
        "x⁻²"   : {"(\($0))⁻²"},
        "x²"    : {"(\($0))²"},
        "x³"    : {"(\($0))³"}
    ]
    
    mutating func performOperation(_ symbol: String){
        
        if let operation = operations[symbol]{
            switch operation {
            case .clear:
                sequenceOfOperations = []
                
            case .undo:
                sequenceOfOperations.removeLast()
                
            default:
                sequenceOfOperations.append(OperationKeys.symbol(symbol))
            }
        }
    }
    
    mutating func setOperand(_ operand: Double){
        sequenceOfOperations.append(OperationKeys.number(operand))
        }
    
    mutating func setOperand(variable named: String){
        sequenceOfOperations.append(OperationKeys.variable(named))
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String){
        
        var result: (value: Double, description: String)? = nil
        var accumulator: (value: Double, description: String)? = nil
        var pendingBinaryOperation: PendingBinaryOperation?
        
        func evaluateResult(using symbol: String){
            if let operation = operations[symbol]{
                switch operation {
                case .constant(let value):
                    accumulator = (value, "\(symbol)")
                    
                case .unaryOperation(let function):
                    if accumulator != nil {
                        accumulator = (function(accumulator!.value), applyUnaryOperation(with: symbol, on: accumulator!.description))
                    }
                    
                case .binaryOperation(let function):
                    if accumulator != nil {
                        accumulator!.description += " \(symbol)"
                        
                        // perform binary operation with current acumulater if we already had one pending
                        if pendingBinaryOperation != nil {
                            performPendingBinaryOperation()
                        }
                        
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!.value)
                        result = accumulator
                        accumulator = nil
                    }
                    
                case .equals:
                    performPendingBinaryOperation()
                    
                default:
                    break
                }
            }
        }
        
        func performPendingBinaryOperation(){
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator!.description = "\(result!.description) \(accumulator!.description) "
                accumulator!.value = pendingBinaryOperation!.perform(with: accumulator!.value)
                pendingBinaryOperation = nil
                result = nil
            }
        }
        
        
        for operation in sequenceOfOperations {
            switch(operation){
            case .variable(let variable):
                // sets accumulator and description of variable
                let variableValue = variables?[variable] ?? 0
                accumulator = (variableValue, variable)
                
            case .number(let value):
                // sets accumulator and removes trailing .0 if an integer to the text
                accumulator = (value, value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value))
                
            case .symbol(let symbol):
                evaluateResult(using: symbol)
            }
        }
        
        return (accumulator?.value , pendingBinaryOperation != nil, result?.description ?? accumulator?.description ?? "")
    }
    
    @available(*, deprecated)
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
    @available(*, deprecated)
    var pendingResult: Bool {
        get {
            return evaluate().isPending
        }
    }
    
    @available(*, deprecated)
    var description: String {
        get {
            return evaluate().description
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private func applyUnaryOperation(with symbol: String, on operationsMade: String ) -> String {
        if let writeComplexOperation = complexWrittenUnaryOperations[symbol]{
            return writeComplexOperation(operationsMade)
            
        }
        return "\(symbol) (\(operationsMade)) "
    }
}
