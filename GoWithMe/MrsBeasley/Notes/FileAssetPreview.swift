//
//  FileAssetPreview.swift
//  HalfRoll
//
//  Created by Kristofer Younger on 8/12/22.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers
import os

struct PreviewController: UIViewControllerRepresentable {
    var url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        print("TFdebug makeUIViewController")

        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {
            print("TFdebug updateUIViewController")
            //uiViewController.reloadData()
        }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        
        var parent: PreviewController
        
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            print("previewController previewItemAt: \(parent.url.absoluteString)")

            return parent.url as NSURL
        }
        
    }
}

final class FileAssetVM: ObservableObject {
    
    @Published var note: Note = .init()
    @Published var tempFile: TemporaryFile
    var filetype: String?
    
    init(aNote: Note) {
        note = aNote
        filetype = UTType(mimeType: aNote.mimetype!)?.preferredFilenameExtension
        let fname = "tempfile." + (filetype ?? "txt")
        tempFile = try! TemporaryFile(creatingTempDirectoryForFilename: fname)
    }
    
    func deleteTempFile() {
        do {
            try self.tempFile.deleteDirectory()
            Foundation.NSLog("TFdebug deleted temp files")
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func resetTempFile() {
        deleteTempFile()
        let fname = "tempfile." + (filetype ?? "txt")
        self.tempFile = try! TemporaryFile(creatingTempDirectoryForFilename: fname)
        
        print("TFdebug NEW temp file \(self.tempFile.fileURL.absoluteString)")
        
        loadTempFile()
        
    }
    
    func loadTempFile() {
        print("loadTempFile \(note.title!) \(tempFile.fileURL)")
        if let blob = note.blob {
                try! blob.write(to: tempFile.fileURL)
            }
    }
    
}

struct FileAssetPreview: View {
    @ObservedObject var note: Note
    var vm: FileAssetVM

    init(n: Note) {
        note = n
        vm = FileAssetVM(aNote: n)
    }
    
    var body: some View {
        PreviewController(url: vm.tempFile.fileURL)
                .border(.blue)
    }
}

struct FileAssetPreview_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
