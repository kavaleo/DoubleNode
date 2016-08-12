//
//  DNLabel.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

typedef enum
{
    DNLabelVerticalAlignmentCenter  = TTTAttributedLabelVerticalAlignmentCenter,
    DNLabelVerticalAlignmentTop     = TTTAttributedLabelVerticalAlignmentTop,
    DNLabelVerticalAlignmentBottom  = TTTAttributedLabelVerticalAlignmentBottom,
}
DNLabelVerticalAlignment;

@interface DNLabel : TTTAttributedLabel

@property (nonatomic, assign) float verticalPadding;
@property (nonatomic, assign) float horizontalPadding;

@end
