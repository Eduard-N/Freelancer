//
//  String.swift
//  Freelancer
//
//  Created by Kais Segni on 14/06/2021.
//

import Foundation

extension String {
    var localized: String {
        // Is this a good aproach to handle localization?
        // In case in the app there are 2 strings defined as "Description", the translator will not
        // know which string version will be changed so he will replace in his mind "Description" with
        // "Project description" but without being aware that a session "Description" was also in the project.
        // This will result in "Project description" appearing for both project and session screens
        NSLocalizedString(self, value: "\(self)", comment: "")
    }
}
