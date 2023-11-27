// https://github.com/abdelrahmanTD/TaskToDo
// very cool and easy to inject.
// had to make changes to the Data Model in the xcdatamodel

import SwiftUI

struct TaskListRow: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext // to save the updates
    
    var body: some View {
        Toggle(isOn: self.$task.complete) { 
            HStack {
                Text(self.task.name ?? "unnamed")
                    .fontWeight(.bold)
                    .strikethrough(self.task.complete, color: self.task.priority.priorityColor())
                    .opacity(self.task.complete ? 0.5 : 1)
                
                Spacer()
                
                Circle()
                    .frame(width: 10)
                    .foregroundColor(self.task.priority.priorityColor())
            } //: HStack
        } //: Toggle
        .toggleStyle(CheckboxStyle(taskColor: self.task.priority.priorityColor()))
        .onReceive(self.task.objectWillChange) { _ in
            viewContext.flushChanges()
        }
    }
}

// you may remove this preview or update it like this
struct TaskListRow_Previews: PreviewProvider {
    static var previews: some View {
        let testTask = Task(context: PersistenceController.preview.container.viewContext)
        testTask.id = UUID()
        testTask.name = "Test Task"
        testTask.complete = false
        testTask.priority = .normal
        
        return TaskListRow(task: testTask)
    }
}
