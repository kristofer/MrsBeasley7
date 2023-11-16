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
//        print("fileassetvm PreviewController makeUIViewController")

        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {
            if context.coordinator.parent.url.absoluteURL != self.url.absoluteURL {
                context.coordinator.urlToDisplay = self.url
                uiViewController.refreshCurrentPreviewItem()
            }
        }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        
        var parent: PreviewController
        var urlToDisplay: URL
        
        init(parent: PreviewController) {
            self.parent = parent
            self.urlToDisplay = parent.url
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            //print("fileassetvm Coordinator previewItemAt: \(self.urlToDisplay.absoluteString)")
            return self.urlToDisplay as QLPreviewItem
        }
        
    }
}

final class FileAssetVM: ObservableObject {
    
    @Published var note: Note //= .init()
    @Published var tempFile: TemporaryFile
    @Published var tfileURL: URL
    var filetype: String?
    
    init(aNote: Note) {
        note = aNote
        filetype = UTType(mimeType: aNote.mimetype!)?.preferredFilenameExtension
        let fname = "tempfile." + (filetype ?? "txt")
        let ttfile = try! TemporaryFile(creatingTempDirectoryForFilename: fname)
        tempFile = ttfile
        tfileURL = ttfile.fileURL
        //print("fileassetvm SETTING UP FILEASSETVM \(aNote.title!)")
        if let blob = note.blob {
            try! blob.write(to: tempFile.fileURL, options: .atomic )
            }

    }
    
    func deleteTempFile() {
        do {
            try self.tempFile.deleteDirectory()
            //print("fileassetvm deleted temp files \(note.title)")
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func resetTempFile() {
        deleteTempFile()
        filetype = UTType(mimeType: note.mimetype!)?.preferredFilenameExtension
        let fname = "tempfile." + (filetype ?? "txt")
        self.tempFile = try! TemporaryFile(creatingTempDirectoryForFilename: fname)
        self.tfileURL = self.tempFile.fileURL
        //print("fileassetvm  \(fname) \(note.title) NEW temp file \(self.tempFile.fileURL.absoluteString)")
        
        loadTempFile()
        
    }
    
    func loadTempFile() {
        //print("fileassetvm loadTempFile \(note.title!) \(tempFile.fileURL)")
        tfileURL = tempFile.fileURL
        filetype = UTType(mimeType: note.mimetype!)?.preferredFilenameExtension

        if let blob = note.blob {
            try! blob.write(to: tempFile.fileURL, options: .atomic )
            }
    }
    
}

struct FileAssetView: View {
    @ObservedObject var note: Note
    var vm: FileAssetVM

    init(n: Note) {
        note = n
        vm = FileAssetVM(aNote: n)
        //_vm = StateObject(wrappedValue: FileAssetVM(aNote: n))
    }
    
    var body: some View {
//        Text("FileAssetView vm \(vm.note.title!)")
//        Text("FileAssetView note \(note.title!)")
        FileAssetPreview(vm: vm)
            .onChange(of: self.note, perform: { _ in
                vm.resetTempFile()
            })
            .onDisappear() {
                vm.deleteTempFile()
            }
            .onAppear() {
                vm.loadTempFile()
            }
    }
}

struct FileAssetPreview: View {
    @ObservedObject var vm: FileAssetVM
    
    var body: some View {
//        Text("FileAssetPreview \(vm.note.title!)")
        PreviewController(url: vm.tfileURL)
    }
}
