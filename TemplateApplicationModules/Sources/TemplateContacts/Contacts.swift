//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Contact
import Foundation
import SwiftUI


/// Displays the contacts for the CardinalKit Template Application.
public struct Contacts: View {
    let contacts = [
        Contact(
            name: PersonNameComponents(
                givenName: "Leland",
                familyName: "Stanford"
            ),
            image: Image(systemName: "figure.wave.circle"),
            title: "University Founder",
            description: String(localized: "LELAND_STANFORD_BIO", bundle: .module),
            organization: "Stanford University",
            address: {
                let address = CNMutablePostalAddress()
                address.country = "USA"
                address.state = "CA"
                address.postalCode = "94305"
                address.city = "Stanford"
                address.street = "450 Serra Mall"
                return address
            }(),
            contactOptions: [
                .call("+1 (650) 723-2300"),
                .text("+1 (650) 723-2300"),
                .email(addresses: ["contact@stanford.edu"]),
                ContactOption(
                    image: Image(systemName: "safari.fill"),
                    title: "Website",
                    action: {
                        if let url = URL(string: "https://stanford.edu") {
                           UIApplication.shared.open(url)
                        }
                    }
                )
            ]
        )
    ]
    
    
    public var body: some View {
        NavigationStack {
            ContactsList(contacts: contacts)
                .navigationTitle(String(localized: "CONTACTS_NAVIGATION_TITLE", bundle: .module))
        }
    }
    
    
    public init() {}
}


struct Contacts_Previews: PreviewProvider {
    static var previews: some View {
        Contacts()
    }
}
