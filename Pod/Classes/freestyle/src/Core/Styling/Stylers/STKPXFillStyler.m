/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  PXFillStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXFillStyler.h"
#import "STKPXPaintGroup.h"
#import "NSArray+Reverse.h"

@implementation STKPXFillStyler

#pragma mark - Static Methods

+ (STKPXFillStyler *)sharedInstance
{
	static __strong STKPXFillStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[STKPXFillStyler alloc] init];
	});

	return sharedInstance;
}

#pragma mark - Overrides

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
            @"background-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                context.fill = declaration.paintValue;
            },
            @"background-size" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                context.imageSize = declaration.sizeValue;
            },
            @"background-inset" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                context.insets = declaration.insetsValue;
            },
            @"background-inset-top" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(value, insets.left, insets.bottom, insets.right);
            },
            @"background-inset-right" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, value);
            },
            @"background-inset-bottom" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(insets.top, insets.left, value, insets.right);
            },
            @"background-inset-left" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                UIEdgeInsets insets = context.insets;
                CGFloat value = declaration.floatValue;

                context.insets = UIEdgeInsetsMake(insets.top, value, insets.bottom, insets.right);
            },
            @"background-image" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                id<PXPaint> paint = declaration.paintValue;

                if ([paint isKindOfClass:[STKPXPaintGroup class]])
                {
                    STKPXPaintGroup *group = (STKPXPaintGroup *) paint;

                    context.imageFill = [[STKPXPaintGroup alloc] initWithPaints:[group.paints reversedArray]];
                }
                else
                {
                    context.imageFill = declaration.paintValue;
                }
            },
            @"background-padding" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                context.padding = declaration.offsetsValue;
            },
            @"background-top-padding" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[STKPXOffsets alloc] initWithTop:value right:padding.right bottom:padding.bottom left:padding.left];
            },
            @"background-right-padding" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[STKPXOffsets alloc] initWithTop:padding.top right:value bottom:padding.bottom left:padding.left];
            },
            @"background-bottom-padding" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[STKPXOffsets alloc] initWithTop:padding.top right:padding.right bottom:value left:padding.left];
            },
            @"background-left-padding" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXOffsets *padding = [self paddingFromContext:context];
                CGFloat value = declaration.floatValue;

                context.padding = [[STKPXOffsets alloc] initWithTop:padding.top right:padding.right bottom:padding.bottom left:value];
            },
        };
    });

    return handlers;
}

- (STKPXOffsets *)paddingFromContext:(STKPXStylerContext *)context
{
    STKPXOffsets *result = context.padding;

    if (!result)
    {
        result = [[STKPXOffsets alloc] init];
    }

    return result;
}

@end
