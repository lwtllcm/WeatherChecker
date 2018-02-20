//
//  CoreDataStack.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/18/16.
//  Copyright © 2016 Student. All rights reserved.
//

import CoreData

// MARK:  - TypeAliases
typealias BatchTask=(_ workerContext: NSManagedObjectContext) -> ()

// MARK:  - Notifications
enum CoreDataStackNotifications : String{
    case ImportingTaskDidFinish = "ImportingTaskDidFinish"
}
// MARK:  - Main
struct CoreDataStack {
    
    // MARK:  - Properties
    //private let model : NSManagedObjectModel
     let model : NSManagedObjectModel

    //private let coordinator : NSPersistentStoreCoordinator
    let coordinator : NSPersistentStoreCoordinator
    
    //private let modelURL : NSURL
    let modelURL : NSURL

    //private let dbURL : NSURL
    let dbURL : NSURL

    //private let persistingContext : NSManagedObjectContext
    let persistingContext : NSManagedObjectContext

    //private let backgroundContext : NSManagedObjectContext
    let backgroundContext : NSManagedObjectContext

    let context : NSManagedObjectContext
    
    
    // MARK:  - Initializers
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil}
        
        self.modelURL = modelURL as NSURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.name = "Persisting"
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        context.name = "Main"
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        backgroundContext.name = "Background"
        
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let  docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        
        //self.dbURL = docUrl.URLByAppendingPathComponent("model.sqlite")
        self.dbURL = docUrl.appendingPathComponent("model.sqlite") as NSURL
        
        
        do{
            try addStoreTo(coordinator: coordinator,
                           storeType: NSSQLiteStoreType,
                           configuration: nil,
                           storeURL: dbURL,
                           options: nil)
            
        }catch{
            print("unable to add store at \(dbURL)")
        }
        
        
        
        
        
    }
    
    // MARK:  - Utils
    func addStoreTo(coordinator coord : NSPersistentStoreCoordinator,
                                storeType: String,
                                configuration: String?,
                                storeURL: NSURL,
                                options : [NSObject : AnyObject]?) throws{
        //
        let migrateOptions = [NSInferMappingModelAutomaticallyOption:true, NSMigratePersistentStoresAutomaticallyOption:true]
        
        //try coord.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        try coord.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL as URL, options: migrateOptions)
        
        
    }
}


// MARK:  - Removing data
extension CoreDataStack  {
    
    //func dropAllData() throws{
    
    func dropAllData(coord : NSPersistentStoreCoordinator,
                     dbURL: NSURL)
        
        throws{

        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coord.destroyPersistentStore(at: dbURL as URL, ofType:NSSQLiteStoreType , options: nil)
        
        
        
        //try addStoreTo(coordinator: self.coordinator, storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        
        
    }
}

// MARK:  - Batch processing in the background
extension CoreDataStack{
    
    
    func performBackgroundBatchOperation(batch: @escaping BatchTask){
        
        self.backgroundContext.perform(){
            batch(self.backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do{
                try self.backgroundContext.save()
            }catch{
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK:  - Heavy processing in the background.
// Use this if importing a gazillion objects.
extension CoreDataStack {
    
    func performBackgroundImportingBatchOperation(batch: @escaping BatchTask) {
        
        // Create temp coordinator
        //let tmpCoord = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let tmpCoord = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        
        do{
            try addStoreTo(coordinator: tmpCoord, storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        }catch{
            fatalError("Error adding a SQLite Store: \(error)")
        }
        
        // Create temp context
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.name = "Importer"
        moc.persistentStoreCoordinator = tmpCoord
        
        // Run the batch task, save the contents of the moc & notify
        moc.perform(){
            batch(moc)
            
            do {
                try moc.save()
            }catch{
                fatalError("Error saving importer moc: \(moc)")
            }
            
            let nc = NotificationCenter.default
            let n = NSNotification(name: NSNotification.Name(rawValue: CoreDataStackNotifications.ImportingTaskDidFinish.rawValue),
                object: nil)
            nc.post(n as Notification)
        }
        
        
        
    }
}


// MARK:  - Save
extension CoreDataStack {
    
    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performAndWait(){
            
            if self.context.hasChanges{
                do{
                    try self.context.save()
                }catch{
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.perform(){
                    do{
                        try self.persistingContext.save()
                        print("persisting context")
                    }catch{
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
                
                
            }
        }
        
        
        
    }
    
    func saveContext() throws{
        if context.hasChanges {
            try context.save()
            print("saved count",context.insertedObjects.count)
        }
        
    }
    
    
    func autoSave(delayInSeconds : Int){
        
        if delayInSeconds > 0 {
            print("autosaving")
            save()
            
            _ = UInt64(delayInSeconds) * NSEC_PER_SEC
            //let time = DispatchTime.now(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delayInNanoSeconds))
            let time = DispatchTime.now()

            
            //dispatch_after(time as! dispatch_time_t, DispatchQueue.main, {
            DispatchQueue.main.asyncAfter(deadline: time, execute: {

            self.autoSave(delayInSeconds: delayInSeconds)
            })
            
        }
}
}
