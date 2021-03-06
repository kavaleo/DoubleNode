//
//  UIView+ImageOfView.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ImageOfView)

- (UIImage*)imageOfView;
- (UIImage*)imageOfViewInFrame:(CGRect)frame;

@end
