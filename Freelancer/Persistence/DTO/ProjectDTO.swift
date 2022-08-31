//
//  ProjectDTO.swift
//  Freelancer
//
//  Created by Kais Segni on 12/06/2021.
//

import Foundation

struct ProjectDTO: Identifiable {
    var id: UUID = UUID()
    var name = ""
    var completed = false
    var sessions = [SessiontDTO]()
}
