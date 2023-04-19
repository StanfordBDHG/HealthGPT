//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct IconView: View {
    let size: Double


    var body: some View {
        Image(uiImage: Bundle.main.image(withName: "AppIcon", fileExtension: "png"))
            .resizable()
            .scaledToFill()
            .accessibilityLabel(Text("App Icon"))
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size / 5))
            .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 4)
            .padding(.bottom)
    }


    init(size: Double = 150) {
        self.size = size
    }
}


#if DEBUG
struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground)
            IconView(size: 100)
        }
    }
}
#endif
