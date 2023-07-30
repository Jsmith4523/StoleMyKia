//
//  FalseReportView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/29/23.
//

import SwiftUI

struct FalseReportView: View {
    
    @State private var isUploading = false
    
    @State private var presentError = false
    @State private var presentSuccessAlert = false
    
    @State private var comments = ""
        
    @State private var reportVehicleImage: UIImage?
    @State private var falseReportType: FalseReportType?
    
    let report: Report
    
    @EnvironmentObject var userVM: UserViewModel

    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 25)
                    VStack(spacing: 23) {
                        Image(systemName: "exclamationmark.shield")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.red)
                        Text("Tell us why this report is false..")
                            .font(.system(size: 25).weight(.heavy))
                        Divider()
                    }
                    ForEach(FalseReportType.allCases) { type in
                        falseReportTypeCellView(type)
                            .onTapGesture {
                                self.falseReportType = type
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        Divider()
                    }
                    Spacer()
                        .frame(height: 50)
                    if !(falseReportType == nil) {
                        VStack(alignment: .leading) {
                            Text("Comments")
                                .font(.system(size: 19).weight(.bold))
                            Text("Please include any comments you have regarding this report. This field is optional.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            TextEditor(text: $comments)
                                .frame(height: 200)
                                .padding(5)
                                .overlay {
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.25))
                                }
                        }
                        .multilineTextAlignment(.leading)
                    }
                }
                .padding()
            }
            .multilineTextAlignment(.center)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !(falseReportType == nil) {
                        Button("Send") {
                            uploadFalseReport()
                        }
                    } else if isUploading {
                        ProgressView()
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .tint(Color(uiColor: .label))
        .onAppear {
            getVehicleImage()
        }
        .disabled(isUploading)
        .alert("There was an error.", isPresented: $presentError) {
            Button("OK") {}
        } message: {
            Text("Sorry, we were unable to complete that request. Please try again later")
        }
        .alert("Thank you! Your complaint has been sent", isPresented: $presentSuccessAlert) {
            Button("Great") { dismiss() }
        } message: {
            Text("Once received, we will review and determine a decision.")
        }
    }
    
    private func getVehicleImage() {
        ImageCache.shared.getImage(report.imageURL) { image in
            self.reportVehicleImage = image
        }
    }
    
    @ViewBuilder
    func falseReportTypeCellView(_ type: FalseReportType) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(type.rawValue)
                    .font(.system(size: 16.75).weight(.heavy))
                Text(type.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            if let falseReportType, falseReportType == type {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical)
        .multilineTextAlignment(.leading)
    }
    
    private func uploadFalseReport() {
        isUploading = true
        
        guard let falseReportType else {
            isUploading = false
            return
        }
        
        guard let uid = userVM.uid else {
            isUploading = false
            presentError = true
            return
        }
        
        let falseReport = FalseReport(uid: uid, report: report, type: falseReportType, comments: comments)
        
        Task {
            do {
                try await FalseReportManager.shared.uploadFalseReport(falseReport)
                isUploading = false
                presentSuccessAlert = true
            } catch {
                isUploading = false
                presentError = true
            }
        }
    }
}

struct FalseReportView_Previews: PreviewProvider {
    static var previews: some View {
        FalseReportView(report: [Report].testReports().first!)
            .environmentObject(UserViewModel())
    }
}
