//
//  DNManagedObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNManagedObject.h"

#import "DNDataModel.h"
#import "DNModel.h"

#import "DNUtilities.h"
#import "NSString+HTML.h"
#import "NSString+Inflections.h"

@implementation DNManagedObject

@dynamic id;

#pragma mark - Entity description functions

+ (Class)entityModelClass
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base entityModelClass: should never be called, override might be missing!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return nil;
}

+ (DNModel*)entityModel
{
    return [[[self entityModelClass] alloc] init];
}

+ (NSString*)entityName
{
    // Assume a 3-character prefix to class name and no suffix
    return [NSStringFromClass([self class]) substringFromIndex:3];
}

+ (id)entityIDWithDictionary:(NSDictionary*)dict
{
    if ([[dict objectForKey:@"id"] isKindOfClass:[NSString class]])
    {
        return [self dictionaryString:dict withItem:@"id" andDefault:nil];
    }

    return [self dictionaryNumber:dict withItem:@"id" andDefault:nil];
}

+ (NSString*)pathForEntity
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base pathForEntity: should never be called, override might be missing!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return @"";
}

+ (NSString*)requestWithParameters:(NSDictionary**)parameters
                       withContext:(NSManagedObjectContext*)context
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base requestWithParameters:withContext: should never be called, override might be missing!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return nil;
}

+ (NSDictionary*)representationsByEntityOfEntity:(NSEntityDescription*)entity
                             fromRepresentations:(id)representations
{
    return @{entity.name: representations};
}

+ (NSString*)resourceIdentifierForRepresentation:(NSDictionary*)representation
                                        ofEntity:(NSEntityDescription*)entity
                                    fromResponse:(NSHTTPURLResponse*)response
{
    return nil;
}

+ (NSDictionary*)representationsByEntityForRelationshipsFromRepresentation:(NSDictionary*)representation
                                                                  ofEntity:(NSEntityDescription*)entity
                                                              fromResponse:(NSHTTPURLResponse*)response
{
    return nil;
}

+ (NSString*)translationForAttribute:(NSString*)attribute
                            ofEntity:(NSEntityDescription*)entity
{
    if ([attribute rangeOfString:@"_"].location == NSNotFound)
    {
        return attribute;
    }

    NSString*   retval = [(NSString*)attribute camelizeWithLowerFirstLetter];

    return retval;
}

+ (NSDictionary*)attributesForRepresentation:(NSDictionary*)representation
                                    ofEntity:(NSEntityDescription*)entity
                                fromResponse:(NSHTTPURLResponse*)response
{
    NSMutableDictionary*    retRepresentation   = [[NSMutableDictionary alloc] initWithCapacity:representation.count];
    NSDictionary*           attributes          = [entity attributesByName];

    [representation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             return;
         }

         NSString*                  name        = [self translationForAttribute:key ofEntity:entity];
         NSAttributeDescription*    attribute   = [attributes objectForKey:name];
         if (!attribute)
         {
             return;
         }

         switch (attribute.attributeType)
         {
             case NSInteger16AttributeType:
             case NSInteger32AttributeType:
             case NSInteger64AttributeType:
             {
                 [retRepresentation setObject:[self dictionaryNumber:representation dirty:nil withItem:key andDefault:@0] forKey:name];
                 break;
             }

             case NSBooleanAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryBoolean:representation dirty:nil withItem:key andDefault:@NO] forKey:name];
                 break;
             }

             case NSDecimalAttributeType:
             case NSDoubleAttributeType:
             case NSFloatAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryDouble:representation dirty:nil withItem:key andDefault:@0.0f] forKey:name];
                 break;
             }

             case NSStringAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryString:representation dirty:nil withItem:key andDefault:@""] forKey:name];
                 break;
             }

             case NSDateAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryDate:representation dirty:nil withItem:key andDefault:kDNDefaultDate_NeverExpires] forKey:name];
                 break;
             }
         }
     }];

    return retRepresentation;
}
 
+ (NSDictionary*)representationsForRelationshipsFromRepresentation:(NSDictionary*)representation
                                                          ofEntity:(NSEntityDescription*)entity
                                                      fromResponse:(NSHTTPURLResponse*)response
{
    NSMutableDictionary*    mutableRelationshipRepresentations = [NSMutableDictionary dictionaryWithCapacity:[entity.relationshipsByName count]];
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id name, id relationship, BOOL* stop)
     {
         id value = [representation valueForKey:name];
         if (value)
         {
             if ([relationship isToMany])
             {
                 NSArray*   arrayOfRelationshipRepresentations = nil;
                 if ([value isKindOfClass:[NSArray class]])
                 {
                     arrayOfRelationshipRepresentations = value;
                 }
                 else
                 {
                     arrayOfRelationshipRepresentations = [NSArray arrayWithObject:value];
                 }

                 [mutableRelationshipRepresentations setValue:arrayOfRelationshipRepresentations forKey:name];
             }
             else
             {
                 [mutableRelationshipRepresentations setValue:value forKey:name];
             }
         }
     }];

    return mutableRelationshipRepresentations;
}

+ (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID*)objectID
                                 inManagedObjectContext:(NSManagedObjectContext*)context
{
    return NO;  // No detail content endpoint calls needed
}

+ (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription*)relationship
                               forObjectWithID:(NSManagedObjectID*)objectID
                        inManagedObjectContext:(NSManagedObjectContext*)context
{
    return NO;  // No detail content endpoint calls needed
}

#pragma mark - AppDelegate access functions

+ (NSManagedObjectContext*)managedObjectContext
{
    return [[[self entityModelClass] dataModel] mainObjectContext];
}

+ (void)saveContext
{
    [[[self entityModelClass] dataModel] saveContext];
}

#pragma mark - Entity initialization functions

+ (instancetype)entity
{
    return [[self alloc] init];
}

+ (instancetype)entityFromDictionary:(NSDictionary*)dict
{
    return [[self alloc] initWithDictionary:dict];
}

+ (instancetype)entityFromID:(id)idValue
{
    return [[self alloc] initWithID:idValue];
}

- (instancetype)init
{
    __block DNManagedObject*    bself   = self;

    [self performBlockAndWait:^(NSManagedObjectContext* context)
     {
         NSEntityDescription*    entity = [NSEntityDescription entityForName:[[self class] entityName] inManagedObjectContext:context];

         bself = [self initWithEntity:entity insertIntoManagedObjectContext:context];
     }];

    self = bself;
    if (self)
    {
        [self clearData];
    }
    
    return self;
}

- (instancetype)initWithID:(id)idValue
{
    id  newSelf = [[[self class] entityModel] getFromID:idValue];
    if (newSelf == nil)
    {
        newSelf = [self init];
    }
    
    self = newSelf;
    if (self)
    {
        self.id = idValue;
    }
    
    return self;
}

- (instancetype)initWithIDIfExists:(id)idValue
{
    id  newSelf = [[[self class] entityModel] getFromID:idValue];
    if (newSelf == nil)
    {
        //newSelf = [self init];
    }

    self = newSelf;
    if (self)
    {
        self.id = idValue;
    }

    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    id  idValue = [[self class] entityIDWithDictionary:dict];
    
    id  newSelf = [[[self class] entityModel] getFromID:idValue];
    if (newSelf == nil)
    {
        newSelf = [self init];
    }
    
    self = newSelf;
    if (self)
    {
        self.id = idValue;
        
        [self loadWithDictionary:dict];
    }
    
    return self;
}

- (void)clearData
{
    /*
    @try
    {
        self.id = nil;
    }
    @catch (NSException *exception)
    {
        DLog(LL_Warning, LD_CoreData, @"exception=%@", exception);
    }
     */
}

- (void)loadWithDictionary:(NSDictionary*)dict
{
    self.id  = [[self class] entityIDWithDictionary:dict];
}

#pragma mark - Entity save/delete functions

- (void)saveContext;
{
    [[self class] saveContext];
}

- (void)deleteWithNoSave
{
    [self performBlock:^(NSManagedObjectContext* context)
     {
         [context deleteObject:self];
     }];
}

- (void)delete
{
    [self deleteWithNoSave];
    [self saveContext];
}

#pragma mark - Entity Description functions

- (NSEntityDescription*)entityDescription
{
    __block NSEntityDescription*    retval;

    [self performBlockAndWait:^(NSManagedObjectContext* context)
     {
         retval = [NSEntityDescription entityForName:[[self class] entityName]
                              inManagedObjectContext:context];
     }];

    return retval;
}

#pragma mark - Dictionary Translation functions

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryBoolean:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryBoolean:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryBoolean:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSNumber*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithInt:[object boolValue]];

            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }

    return retval;
}

- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryNumber:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSNumber*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithInt:[object intValue]];
            
            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryDouble:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryDouble:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryDouble:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSString*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithDouble:[object doubleValue]];
            
            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

- (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [[self class] dictionaryString:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [[self class] dictionaryString:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [[self class] dictionaryString:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    NSString*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if ([object isKindOfClass:[NSArray class]] == YES)
        {
            if (object != (NSArray*)[NSNull null])
            {
                if ([object count] > 0)
                {
                    NSString*   newval  = object[0];
                    
                    if ((retval == nil) || ([newval isEqualToString:retval] == NO))
                    {
                        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                        retval = newval;
                    }
                }
            }
        }
        else
        {
            if ([object isKindOfClass:[NSString class]] == YES)
            {
                if ([object isEqualToString:@"<null>"] == YES)
                {
                    object  = @"";
                }
            }
            else if ([object isKindOfClass:[NSNull class]] == YES)
            {
                object = @"";
            }
            else
            {
                object = [object stringValue];
            }
            if (object != (NSString*)[NSNull null])
            {
                NSString*   newval  = object;
                
                if ((retval == nil) || ([newval isEqualToString:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }
    
    return [retval stringByDecodingXMLEntities];
}

- (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [[self class] dictionaryArray:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [[self class] dictionaryArray:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [[self class] dictionaryArray:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    NSArray*    retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSArray*)[NSNull null])
        {
            if ([object isKindOfClass:[NSArray class]] == YES)
            {
                NSArray*   newval  = object;
                
                if ((retval == nil) || ([newval isEqualToArray:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }
    
    return retval;
}

- (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [[self class] dictionaryDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [[self class] dictionaryDate:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [[self class] dictionaryDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    NSDate*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if ([object isKindOfClass:[NSNumber class]])
        {
            if (object != (NSNumber*)[NSNull null])
            {
                NSDate*   newval  = [NSDate dateWithTimeIntervalSince1970:[object intValue]];

                if ((retval == nil) || ([newval isEqualToDate:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
        else if ([object isKindOfClass:[NSString class]])
        {
            if (object != (NSString*)[NSNull null])
            {
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate*   newval  = [dateFormatter dateFromString:object];
                if (newval == nil)
                {
                    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setAllowsFloats:NO];
                    
                    NSNumber*   timestamp = [numberFormatter numberFromString:object];
                    if (timestamp != nil)
                    {
                        if ([timestamp integerValue] != 0)
                        {
                            newval = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
                        }
                    }
                }
                if (newval)
                {
                    if ((retval == nil) || ([newval isEqualToDate:retval] == NO))
                    {
                        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                        retval = newval;
                    }
                }
            }
        }
    }
    
    return retval;
}

- (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [[self class] dictionaryObject:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [[self class] dictionaryObject:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [[self class] dictionaryObject:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue
{
    id  retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (id)[NSNull null])
        {
            id  newval  = dictionary[key];
            
            if ((retval == nil) || ([newval isEqual:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

#pragma mark - private methods

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                blockAndWait:block];
}

- (void)performBlock:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                       block:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [[[self class] entityModel] performWithContext:context
                                      blockAndWait:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block
{
    [[[self class] entityModel] performWithContext:context
                                             block:block];
}

@end
