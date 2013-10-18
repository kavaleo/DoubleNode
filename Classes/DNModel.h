//
//  DNModel.h
//  Pods
//
//  Created by Darren Ehlers on 9/27/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNUtilities.h"

#import "DNManagedObject.h"
#import "DNModelWatchFetchedObject.h"
#import "DNModelWatchFetchedObjects.h"

typedef void(^DNModelCompletionHandlerBlock)();

@interface DNModel : NSObject

+ (NSString*)entityName;

#pragma mark - AppDelegate access functions

+ (id<DNApplicationDelegate>)appDelegate;
+ (NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObjectModel*)managedObjectModel;
+ (void)saveContext;

+ (instancetype)model;

- (id)init;

- (void)saveContext;

- (NSString*)getFromIDFetchTemplate;
- (NSString*)getAllFetchTemplate;
- (NSArray*)getFromIDSortKeys;
- (NSArray*)getAllSortKeys;

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                         didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;
- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                     andAttributes:(NSArray*)attributes
                         didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;
- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;
- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                       andAttributes:(NSArray*)attributes
                           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (BOOL)checkWatch:(DNModelWatch*)watch;
- (void)retainWatch:(DNModelWatch*)watch;
- (void)releaseWatch:(DNModelWatch*)watch;

- (id)getFromID:(id)idValue;
- (DNModelWatchObject*)getFromID:(id)idValue didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (id)getAll;
- (DNModelWatchObjects*)getAllDidChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (void)deleteAllWithCompletion:(DNModelCompletionHandlerBlock)handler;

@end
