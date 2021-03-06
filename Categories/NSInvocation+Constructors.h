//
//  NSInvocation+Constructors.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Constructors)

+ (id)invocationWithTarget:(NSObject*)targetObject
                  selector:(SEL)selector;

+ (id)invocationWithClass:(Class)targetClass
                 selector:(SEL)selector;

+ (id)invocationWithProtocol:(Protocol*)targetProtocol
                    selector:(SEL)selector;

@end
