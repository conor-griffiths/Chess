//
//  ContentView.swift
//  Chess Analyser_Cape Town
//
//  Created by Conor Griffiths on 22/12/2024.
//

//
//  ContentView.swift
//  Chess Analyser_Cape Town
//
//  Created by Conor Griffiths on 22/12/2024.
//

import SwiftUI
import CoreML
import Vision
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = AnalysisViewModel()
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Chess Position Analyzer")
                .font(.title2) // Reduced size for the title
                .multilineTextAlignment(.center)
                .padding()
            
            // Display the selected image or placeholder
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300) // Slightly reduced image height
                    .padding()
            } else {
                Text("No Image Selected")
                    .foregroundColor(.gray)
                    .font(.body) // Adjust text size
            }
            
            // Select Image Button
            Button("Select Image") {
                showImagePicker = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.body) // Adjust button text size
            
            // Analyze Image Button
            Button("Analyze Image") {
                analyzeImage()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.body) // Adjust button text size
            
            // Analysis Output Section
            Text("Analysis Output:")
                .font(.headline) // Section header
            
            Text(viewModel.analysisOutput)
                .font(.footnote) // Smaller font for output
                .foregroundColor(.gray)
                .padding()
                .multilineTextAlignment(.center)
                .onChange(of: viewModel.analysisOutput) { newValue in
                    print("UI Updated with analysisOutput: \(newValue)")
                }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    private func analyzeImage() {
        guard let selectedImage = selectedImage else {
            viewModel.analysisOutput = "Please select an image first."
            print("No image selected.")
            return
        }
        
        guard let cgImage = selectedImage.cgImage else {
            viewModel.analysisOutput = "Unable to process the image."
            print("Error converting UIImage to CGImage.")
            return
        }
        
        DispatchQueue.main.async {
            self.viewModel.analysisOutput = "Analyzing the image..."
            print("Starting image analysis...")
        }
        
        do {
            let model = try VNCoreMLModel(for: Chess_Layout_ML_1().model)
            print("Core ML model loaded successfully.")
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    print("Vision request error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.viewModel.analysisOutput = "Vision request failed: \(error.localizedDescription)"
                    }
                    return
                }
                
                if let results = request.results as? [VNClassificationObservation] {
                    self.processResults(results)
                } else {
                    print("No predictions returned.")
                    DispatchQueue.main.async {
                        self.viewModel.analysisOutput = "No predictions returned."
                    }
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
            print("Vision request performed successfully.")
            
        } catch {
            print("Error performing Vision request: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.viewModel.analysisOutput = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func processResults(_ results: [VNClassificationObservation]) {
        guard !results.isEmpty else {
            print("Error: No predictions returned.")
            DispatchQueue.main.async {
                self.viewModel.analysisOutput = "No predictions available."
            }
            return
        }
        
        print("Processing results...")
        let topResult = results.max { $0.confidence < $1.confidence } // Get the highest confidence prediction
        
        guard let bestResult = topResult else {
            print("Error: No valid predictions.")
            DispatchQueue.main.async {
                self.viewModel.analysisOutput = "No valid predictions."
            }
            return
        }
        
        let confidence = String(format: "%.2f", bestResult.confidence * 100)
        let outputText = "\(bestResult.identifier): \(confidence)%"
        print("Top Prediction: \(outputText)") // Debugging raw prediction
        
        DispatchQueue.main.async {
            self.viewModel.analysisOutput = outputText // Update UI with the top prediction
        }
    }
}
