//
//  NoteDetail.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

struct NoteDetail: View {
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var note: Note
    @State private var wordCount: Int = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
                .shadow(radius: 10)

            
            VStack {
                NoteDetailHeader(note: note)
                Divider()
                TextEditor(text: $note.body.toUnwrapped(defaultValue: ""))
                    .padding(5)
                Divider()
                if wordCount == 0 && note.body != nil {
                    Text("\(countWords(note.body!)) words")
                        .font(.caption).italic()
                } else {
                    Text("\(wordCount) words")
                        .font(.caption).italic()
                }
            }
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .onChange(of: note.body, perform: { newValue in
                if let s = newValue {
                    self.wordCount = countWords(s)
                } else {
                    self.wordCount = 0
                }
            })
            .padding(10)
            .onDisappear(){
                if moc.hasChanges {
                    do {
                        try moc.save()
                    } catch {
                        let nserror = error as NSError
                        print("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
        }
    }
    
    private func countWords(_ s: String) -> Int {
        var c: Int = 0
        let words = s.split {
            $0 == " " ||
            $0.isNewline
        }
        c = words.count

        return c
    }
}
//
//struct CardView: View {
//    //let card: Card
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 25, style: .continuous)
//                .fill(.white)
//
//            VStack {
//                Text(card.prompt)
//                    .font(.largeTitle)
//                    .foregroundColor(.black)
//
//                Text(card.answer)
//                    .font(.title)
//                    .foregroundColor(.gray)
//            }
//            .padding(20)
//            .multilineTextAlignment(.center)
//        }
//        .frame(width: 450, height: 250)
//    }
//}

struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
