//
//  UserProgress.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/11/22.
//

import Foundation

class UserProgress : ObservableObject {
    @Published var minutes = 0.0
    @Published var pct = 0.0
}
