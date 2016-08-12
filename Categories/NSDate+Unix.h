//
//  NSDate+Unix.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Unix)

- (int)unixTimestamp;
- (NSComparisonResult)unixCompare:(NSDate*)time;

@end
