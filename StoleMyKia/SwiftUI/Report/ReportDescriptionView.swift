//
//  ReportDescriptionView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/20/23.
//

import SwiftUI

struct ReportDescriptionView: View {
    
    @Binding var description: String
    
    @FocusState private var presentKeyboard: Bool
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $description)
                        .focused($presentKeyboard)
                    if description.isEmpty {
                        Text("Please Tell Us What Happened...")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                            .padding(7)
                            .onTapGesture {
                                presentKeyboard = true
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Report Description")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                self.presentKeyboard = true
            }
        }
        .tint(Color(uiColor: .label))
    }
}

struct ReportDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        ReportDescriptionView(description: .constant(""))
    }
}
