//
//  ShopView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct Coffee: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
}

struct ShopView: View {
    let coffees = [
        Coffee(name: "Espresso", price: 2.99),
        Coffee(name: "Cappuccino", price: 3.99),
        Coffee(name: "Latte", price: 4.49),
        Coffee(name: "Mocha", price: 4.99),
        Coffee(name: "Americano", price: 3.49)
    ]
    
    var body: some View {
        List(coffees) { coffee in
            HStack {
                Text(coffee.name)
                Spacer()
                Text("$\(coffee.price, specifier: "%.2f")")
            }
        }
        .navigationTitle("Coffee Shop")
    }
}
