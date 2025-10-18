//
//  ContentView.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI

struct ContentView: View {
    @State private var items: [String] = ["Hello", "World"]

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("My List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addItem()
                    }
                }
            }
        }
    }

    private func addItem() {
        items.append("New Item \(items.count + 1)")
    }

    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
