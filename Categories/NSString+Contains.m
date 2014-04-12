//
//  NSString+Contains.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "NSString+Contains.h"

@implementation NSString (Contains)

- (BOOL)contains:(NSString*)subString
{
    return ([self rangeOfString:subString].location != NSNotFound);
}

@end
