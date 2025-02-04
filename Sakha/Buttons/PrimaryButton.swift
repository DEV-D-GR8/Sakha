//
//  PrimaryButton.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: 265)
            .padding()
            .background(Color("PrimaryColor"))
            .cornerRadius(50)
    }
}
