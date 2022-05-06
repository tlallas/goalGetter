//
//  RadioButtonField.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/6/22.
//

import SwiftUI
//MARK:- Radio Button Field
struct RadioButtonField: View {
    let id: Int
    let label: String
    let topLabel: String
    let size: CGFloat
    let color: Color
    let bgColor: Color
    let textSize: CGFloat
    let isMarked:Bool
    let callback: (Int)->()
    
    init(
        id: Int,
        label:String,
        topLabel: String,
        size: CGFloat = 20,
        color: Color = Color.black,
        bgColor: Color = Color.black,
        textSize: CGFloat = 14,
        isMarked: Bool = false,
        callback: @escaping (Int)->()
        ) {
        self.id = id
        self.label = label
        self.topLabel = topLabel
        self.size = size
        self.color = color
        self.bgColor = bgColor
        self.textSize = textSize
        self.isMarked = isMarked
        self.callback = callback
            
    }
    
    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            VStack(alignment: .center) {
                Text(topLabel)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                Image(systemName: self.isMarked ? "largecircle.fill.circle" : "circle")
                    .clipShape(Circle())
                    .foregroundColor(self.bgColor)
                    .padding(.bottom, 2)
                Text(label)
                    .font(Font.system(size: textSize))
                Spacer()
            }.foregroundColor(self.color)
        }
        .foregroundColor(Color.white)
    }
}
