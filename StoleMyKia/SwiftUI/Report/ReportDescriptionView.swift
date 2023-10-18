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
    
    var characterCountColor: Color {
        if description.count < Int.descriptionMinCharacterCount {
            return .orange
        } else if description.count >= Int.descriptionMinCharacterCount && description.count <= Int.descriptionWarningCharacterCount {
            return Color(uiColor: .label)
        } else if description.count > Int.descriptionWarningCharacterCount && description.count < Int.descriptionMaxCharacterCount {
            return .orange
        }  else if description.count >= Int.descriptionMaxCharacterCount {
            return .red
        }
        return Color(uiColor: .label)
    }
    
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
            .navigationTitle("Description")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(Int.descriptionMaxCharacterCount - description.count)")
                        .foregroundColor(characterCountColor)
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
        ReportDescriptionView(description: .constant("Int.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt.descriptionMaxCharacterCountInt"))
    }
}
