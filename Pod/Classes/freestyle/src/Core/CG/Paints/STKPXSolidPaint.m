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
//  STKPXSolidPaint.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 6/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXSolidPaint.h"
#import "UIColor+STKPXColors.h"

@implementation STKPXSolidPaint

@synthesize blendMode = _blendMode;

#pragma mark - Static Initializers

+ (instancetype)paintWithColor:(UIColor *)color
{
    return [[STKPXSolidPaint alloc] initWithColor:color];
}

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithColor:[UIColor blackColor]];
}

- (instancetype)initWithColor:(UIColor *)aColor
{
    if (self = [super init])
    {
        _color = aColor;
        _blendMode = kCGBlendModeNormal;
    }

    return self;
}

#pragma mark - Getters

- (UIColor *)activeColor
{
    return (_color) ? _color : [UIColor clearColor];
}

- (BOOL)isOpaque
{
    return _color.isOpaque;
}

#pragma mark - Overrides

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;

    if (object && [object isKindOfClass:[STKPXSolidPaint class]])
    {
        STKPXSolidPaint *that = object;

        result = [_color isEqual:that->_color] && _blendMode == that->_blendMode;
    }

    return result;
}

#pragma mark - STKPXPaint implementation

- (void)applyFillToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, [self activeColor].CGColor);

    CGContextAddPath(context, path);

    // set blending mode
    CGContextSetBlendMode(context, _blendMode);

    CGContextFillPath(context);
}

- (id<STKPXPaint>)lightenByPercent:(CGFloat)percent
{
    return [[STKPXSolidPaint alloc] initWithColor:[_color lightenByPercent:percent]];
}

- (id<STKPXPaint>)darkenByPercent:(CGFloat)percent
{
    return [[STKPXSolidPaint alloc] initWithColor:[_color darkenByPercent:percent]];
}

@end
