//
//  CalculatorButtonItem.swift
//  TestSwift5
//
//  Created by dzq_mac on 2020/1/19.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine


enum CalculatorButtonItem {
    
    enum Op:String {
        case plus = "+"
        case minus = "-"
        case multiply = "x"
        case divide = "÷"
        case equal = "="
    }
    
    enum Command:String {
        case clear = "AC"
        case flip = "+/-"
        case persent = "%"
    }
    
    case digit(Int)
    case dot
    case op(Op)
    case command(Command)
    
}

extension CalculatorButtonItem{
    var title :String {
        switch self {
        case .op(let value):
            return value.rawValue
        case .digit(let num):
            return "\(num)"
        case .command(let con):
            return con.rawValue
        case .dot:
            return "."
        }
    }
    
    var size:CGSize {
        if case .digit(let num) = self,num == 0 {
            return CGSize(width: 88 * 2 + 8, height: 88)
        }
        return CGSize(width: 88, height: 88)
    }
    
    var backgroundColor:Color {
        switch self {
        case .command(_):
            return .gray
        case .digit(_),.dot:
            return Color("Color1")
        case .op(_):
            return .orange
        }
    }
    
}
extension CalculatorButtonItem :Hashable{}

//  计算器目前输入的状态
enum CalculatorBrain {
    
    case left(String)
    
    case leftOp(left:String,op:CalculatorButtonItem.Op)
    
    case leftOpRight(
        left:String,
        op:CalculatorButtonItem.Op,
        right:String
    )
    //保留8位
    var formatter:NumberFormatter {
        let f = NumberFormatter()
        f.minimumIntegerDigits = 1
        f.maximumFractionDigits = 8
        f.numberStyle = .decimal
        return f
    }
    
    var output: String {
        let result: String
        
        switch self {
        case .left(let left):
            result = left
        case .leftOp(let left, _):
            result =  left
        case .leftOpRight(_,_ , let right):
            result = right
        }
        
        guard let value = Double(result) else {
            return "Error"
        }
        var valueStr = formatter.string(from: value as NSNumber)!
        if result.hasSuffix(".") {
            valueStr = valueStr + "."
        }
        return valueStr
    }
    
    //点击按钮生成新的CalculatorBrain
    func apply(item: CalculatorButtonItem) -> CalculatorBrain {
        switch item {
        case .digit(let num):
            return apply(num: num)
        case .dot:
            return apply()
        case .op(let op):
            return apply(op: op)
        case .command(let command):
            return apply(command: command) }
    }

    func apply(num:Int? = nil,op:CalculatorButtonItem.Op? = nil,command:CalculatorButtonItem.Command? = nil) -> CalculatorBrain {
        
        if let n = num {
            switch self {
            case .left(let left):
                return .left(left + "\(n)")
            case .leftOp(let left,let op):
                return .leftOpRight(left: left, op: op, right: "\(n)")
            case .leftOpRight(let left, let op, let right):
                return .leftOpRight(left: left, op: op, right: right + "\(n)")
            }
        }
        
        if  let opt = op {
            switch self {
            case .left(let left):
                if opt == .equal{
                    return .left(left)
                }
                return .leftOp(left: left, op: opt)
            case .leftOp(let left, _):
                if opt == .equal{
                    return .left(left)
                }
                return .leftOp(left: left, op: opt)
            case .leftOpRight(let left, let op, let right):
                let value = calculate(left: left, op: op, right: right)
                if opt == .equal {
                    return .left(value)
                }
                return .leftOp(left: value, op: opt)
            }
        }
        
        if let con = command {
            if con == .clear{
                return .left("0")
            }
            switch self {
            case .left(let left):
                if con == .persent {
                    if let num = Double(left){
                       let value = num / 100
                       return .left("\(value)")
                    }
                    return .left(left)
                }else{
                    return left.hasPrefix("-") ? .left( String(left.suffix(left.count - 1))) : .left("-" + left)
                }
            case .leftOp(let left, let op):
                if con == .persent {
                    if let num = Double(left){
                       let value = num*num / 100
                        return .leftOp(left: "\(value)", op: op)
                    }
                    return .leftOp(left:left,op:op)
                }else{
                    return left.hasPrefix("-") ? .leftOp(left: String(left.suffix(left.count - 1)),op: op) : .leftOp(left: ("-" + left),op: op)
                }
            case .leftOpRight(let left, let op, let right):
                if con == .persent {
                    if let num = Double(right){
                       let value = num / 100
                       return .leftOpRight(left: left, op: op, right: "\(value)")
                    }
                    return .leftOpRight(left: left, op: op, right: right)
                }else{
                    return right.hasPrefix("-") ? .leftOpRight(left: left, op: op,right: String(right.suffix(left.count - 1))) : .leftOpRight(left: left, op: op, right: "-" + right)
                }
            }
            
        }
        //按钮是小数点dot“.”
        switch self {
        case .left(let left):
            if left.contains("."){
              return .left(left)
            }
            return .left(left + ".")
        case .leftOp(let left, let op):
            
            return .leftOpRight(left: left, op: op, right: "0.")
        case .leftOpRight(let left, let op, let right):
            if right.contains(".") {
                return .leftOpRight(left: left, op: op, right: right)
            }
            return .leftOpRight(left: left, op: op, right: right + ".")
        }
        
    }
    
    func calculate(left:String,op:CalculatorButtonItem.Op,right:String) -> String {
        guard let leftNum = Double(left) else {
            return right
        }
        guard let rightNum = Double(right)  else {
            return left
        }
        var value : Double = 0
        switch op {
        case .plus:
            value = leftNum + rightNum
        case .minus:
            value = leftNum - rightNum
        case .multiply:
            value = leftNum * rightNum
        case .divide:
            value = leftNum / rightNum
        case .equal:
            value = 0
        }
        
        return "\(value)"
    }
    
}

typealias CalculatorState = CalculatorBrain
typealias CalculatorStateAction = CalculatorButtonItem
struct Reducer {
    static func reduce(state: CalculatorState,action: CalculatorStateAction ) -> CalculatorState{
        
        return state.apply(item: action)
        
    }
}

class CalculatorModel: ObservableObject {
     let objectWillChange = PassthroughSubject<Void, Never>()

    var brain = CalculatorBrain.left("0"){
        willSet{ objectWillChange.send() }
    }
    
    @Published var  history: [CalculatorButtonItem] = []
    
    func apply(_ item:CalculatorButtonItem) {
        brain = brain.apply(item: item)
        history.append(item)
    }
    
}
