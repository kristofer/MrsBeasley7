//
//  macEditorTextView.swift
//  GoWithMe
//
//  Created by Kristofer Younger on 4/16/24.
//
//
//  MacEditorv2.swift
//
//  Created by Marc Maset - 2021
//  https://bluelemonbits.com
//  https://twitter.com/MarcMasVi
//
import Combine
import SwiftUI

struct MacEditorv2: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    var theTextView = UITextView()
    
    @Binding var text: String
    
    func makeUIView(context: Context) -> UIScrollView {
        let textView = theTextView
        textView.delegate = context.coordinator
        textView.text = text
        
        
        return theTextView
    }
    
    func updateUIView(_ nsView: UIScrollView, context: Context) {

    }
    
    
}

extension MacEditorv2{
    
    class Coordinator: NSObject, UITextViewDelegate{
        
        var parent: MacEditorv2
        var affectedCharRange: NSRange?
        
        init(_ parent: MacEditorv2) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? UITextView else {
                return
            }
            
            //Update text
            self.parent.text = textView.text
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn affectedCharRange: NSRange, replacementText replacementString: String?) -> Bool {
            return true
        }
        
    }
    
    
}
