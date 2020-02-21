//
//  ContentView.swift
//  TestSwift5
//
//  Created by dzq_mac on 2020/1/19.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import SwiftUI
import Combine
struct ContentView: View {
    
    let scale:CGFloat = UIScreen.main.bounds.width / 414
    
//    @State var brain:CalculatorBrain = .left("0")
    @ObservedObject var model = CalculatorModel()
    var body: some View {
        VStack( spacing: 13.0) {
            Spacer()
            Button("操作履历: \(model.history.count)") {
                print(self.model.history)
            }
            Text(model.brain.output)
                .font(.system(size: 76))
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .minimumScaleFactor(0.5)
                .padding(.trailing,24 * scale)

            CalculatorButtonPad(model: model)
        }
        .scaleEffect(scale)
//        .frame( maxHeight: .infinity, alignment: .bottom)
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ContentView()
            //查看在对应设备上显示
//            ContentView().previewDevice("iPhone SE")
        }
    }
}

struct CalculatorBUtton: View {
    let fontSIze:CGFloat = 38
    let title :String
    let size:CGSize
    let backgroundColor:Color
    let action :()->Void
    
    var body: some View {
        
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSIze))
                .foregroundColor(.white)//Color 也是一个遵守 View 协议的类型
                .frame(width: size.width, height: size.height)
                .background(backgroundColor)
                .cornerRadius(size.width/2)
//                .clipShape(Circle())

        }
        
//        ZStack {
//
//            Text(title)
//               .font(.system(size: fontSIze))
//               .foregroundColor(.white)//Color 也是一个遵守 View 协议的类型
//               .frame(width: size.width, height: size.height)
//               .background(backgroundColor)
//                .clipShape(Circle())
//               .onTapGesture {
//                print("click-\(self.title)")
//            }
//
//        }
        
        
    }
}

struct CalculatorButtonRow: View {
    let row:[CalculatorButtonItem]
//    @Binding var brain : CalculatorBrain
    var model:CalculatorModel
    var body: some View {
        HStack(spacing:8){
            ForEach(row, id: \.self) { item in
                CalculatorBUtton(title: item.title, size: item.size, backgroundColor: item.backgroundColor) {
                    self.model.apply(item)
                }
                
            }
        }
        .padding(0.0)
    }
}

struct CalculatorButtonPad: View {
    let rows:[[CalculatorButtonItem]] = [
        [.command(.clear),.command(.flip),.command(.persent),.op(.divide)],
        [.digit(7),.digit(8),.digit(9),.op(.multiply)],
        [.digit(4),.digit(5),.digit(6),.op(.minus)],
        [.digit(1),.digit(2),.digit(3),.op(.plus)],
        [.digit(0),.dot,.op(.equal)]
    ]
    
//    @Binding var brain : CalculatorBrain
    var model:CalculatorModel
    var body: some View {
        VStack(spacing:8) {
            ForEach(rows, id: \.self, content: { row in
                CalculatorButtonRow(row: row,model: self.model)
            })
        }
        .padding(0.0)
        
    }
}
