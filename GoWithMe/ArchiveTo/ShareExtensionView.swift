//
//  ShareExtensionView.swift
//  ArchiveTo
//
//  Created by Kristofer Younger on 3/19/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShareExtensionView: View {
    let sharedURL: String?
    let sharedText: String?
    let sharedPDFData: Data?
    let onSave: (String, String) -> Void
    let onCancel: () -> Void
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var isSaving: Bool = false
    @FocusState private var titleFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Preview Card (if URL exists)
                if let url = sharedURL {
                    URLPreviewCard(url: url)
                        .padding()
                }
                
                // Input Form
                Form {
                    Section(header: Text("Title")) {
                        TextField("Give this note a title", text: $title)
                            .font(.headline)
                            .focused($titleFieldFocused)
                    }
                    
                    Section(header: Text("Notes (Optional)")) {
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .font(.body)
                    }
                    
                    if let pdfData = sharedPDFData {
                        Section {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.red)
                                Text("PDF Attached")
                                    .font(.subheadline)
                                Spacer()
                                Text(formatBytes(pdfData.count))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Save to Mrs. Beasley")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty || isSaving)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Pre-fill title if we have a URL
                if let url = sharedURL, title.isEmpty {
                    title = extractDomain(from: url)
                }
                // Focus the title field
                titleFieldFocused = true
            }
        }
    }
    
    private func saveNote() {
        isSaving = true
        
        // Call the save callback - the parent handles dismissal
        onSave(title, notes)
    }
    
    private func extractDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return "Untitled"
        }
        
        // Remove www. prefix if present
        let domain = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        
        // Capitalize first letter
        return domain.prefix(1).uppercased() + domain.dropFirst()
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - URL Preview Card

struct URLPreviewCard: View {
    let url: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "link.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text("Web Link")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Text(url)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#Preview("With URL") {
    ShareExtensionView(
        sharedURL: "https://ten.boardnotebook.com/boards/ea90fd94-ebdf-4063-b8e2-b4189c03d52e",
        sharedText: nil,
        sharedPDFData: nil
    ) { title, notes in
        print("Saving: \(title), \(notes)")
    } onCancel: {
        print("Cancelled")
    }
}

#Preview("With PDF") {
    ShareExtensionView(
        sharedURL: "https://example.com/document.pdf",
        sharedText: nil,
        sharedPDFData: Data(count: 1_500_000)
    ) { title, notes in
        print("Saving: \(title), \(notes)")
    } onCancel: {
        print("Cancelled")
    }
}

#Preview("Plain Text") {
    ShareExtensionView(
        sharedURL: nil,
        sharedText: "Some shared text content",
        sharedPDFData: nil
    ) { title, notes in
        print("Saving: \(title), \(notes)")
    } onCancel: {
        print("Cancelled")
    }
}
