//
//  NoteBody.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

struct NoteBody: View {
    @Binding var content: String
    
    var body: some View {
            TextEditor(text: $content)
        }
}

struct NoteBody_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
