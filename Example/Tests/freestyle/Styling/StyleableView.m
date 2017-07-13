//
//  StyleableView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 9/30/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "StyleableView.h"
#import "PXStyleable.h"
#import "UIView+PXStyling.h"

@implementation StyleableView
{
    NSString *elementName;
}

- (instancetype)initWithElementName:(NSString *)name
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self->elementName = name;
    }
    return self;
}

- (NSString *)pxStyleElementName
{
    return self->elementName;
}

- (NSString *)description
{
    id parent = self.pxStyleParent;
    NSString *parentName = ([parent conformsToProtocol:@protocol(PXStyleable)]) ? ((id<PXStyleable>) parent).pxStyleElementName : @"nil";

    return [NSString stringWithFormat:@"<StyleableView parent='%@' name='%@'>", parentName, self.pxStyleElementName];
}

@end
