//
//  ContentView.swift
//  FlexiblePickerExample
//
//  Created by Jędrzej Chołuj on 23/01/2022.
//

import SwiftUI
import CoreData

class FlexTagViewModel: ObservableObject {
    
    @Published var tags: [SelectableTagModel] = []
    var viewContext: NSManagedObjectContext?
    
    //init() {}
    
    func initTags(n: Note?, vc: NSManagedObjectContext) {
        self.tags = Tag.allTagsSelectable(vc: vc)
        if let n = n, let ftags = n.tags {
            let ftags = Array(ftags) as! [Tag]
            for ftag in ftags {
                //let ftag = (tag as Tag)
                for i in 0..<self.tags.count {
                    if self.tags[i].displayedTag.uuid?.uuidString == ftag.uuid?.uuidString {
                        self.tags[i].isSelected = true
                    }
                }
            }
        }
    }
    
    func save() {
        if let vc = viewContext {
            vc.flushChanges()
        }
    }
}

struct ContentTagView: View {
    @Environment(\.managedObjectContext) var viewContext

    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var vm: FlexTagViewModel
    
    var note: Note
    
    init(note: Note, isPresented: Binding<Bool>) {
        self.note = note
        self.vm = FlexTagViewModel()
    }
    
    var body: some View {
        VStack{
            Text("Tags assigned")
            Divider()
            FlexiblePicker<SelectableTagModel>(inputData: $vm.tags, item: note)
                .padding(10)
            Divider()
            Button("Done.") {
                vm.save()
                dismiss()
            }
                .buttonStyle(.bordered)
        }
        .onAppear(){
            vm.initTags(n: note, vc: viewContext)
        }
        .onDisappear() {
            vm.save()
        }
    }
    
}

struct ContentTagView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
        
    }
}
