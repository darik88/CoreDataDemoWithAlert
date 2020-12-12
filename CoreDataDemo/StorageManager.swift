//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Айдар Рахматуллин on 26.11.2020.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print(error)
            return []
        }
    }
    
    
    func save(taskName: String, completion: (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        
//         let task = Task(context: context)
                
        task.name = taskName
        completion(task)
        saveContext()
    }
    
    
    func delete(taskName: Task, at indexPath: IndexPath) {
        context.delete(taskName)
        saveContext()
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
