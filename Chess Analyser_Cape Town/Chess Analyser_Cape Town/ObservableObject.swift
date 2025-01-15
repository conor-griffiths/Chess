//
//  ObservableObject.swift
//  Chess Analyser_Cape Town
//
//  Created by Conor Griffiths on 12/01/2025.
//

import SwiftUI
import Combine

class AnalysisViewModel: ObservableObject {
    @Published var fenPosition: String = "Enter FEN and Analyze"
    @Published var analysisOutput: String = "Model predictions will appear here."
}
