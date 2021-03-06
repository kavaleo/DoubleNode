//
//  UIView+ViewWithNibName.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewWithNibName)

+ (UIView*)viewWithNibName:(NSString*)nibName owner:(NSObject*)owner;

@end
