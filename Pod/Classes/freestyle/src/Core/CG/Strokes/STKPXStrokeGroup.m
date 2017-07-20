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
//  STKPXStrokeGroup.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXStrokeGroup.h"

@implementation STKPXStrokeGroup
{
    NSMutableArray *strokes_;
}

#pragma mark - Methods

- (void)addStroke:(id<STKPXStrokeRenderer>)stroke
{
    if (stroke)
    {
        if (strokes_ == nil)
        {
            strokes_ = [NSMutableArray array];
        }

        [strokes_ addObject:stroke];
    }
}

#pragma mark - Getters

- (BOOL)isOpaque
{
    BOOL result = YES;

    for (id<STKPXStrokeRenderer> stroke in strokes_)
    {
        if (stroke.isOpaque == NO)
        {
            result = NO;
            break;
        }
    }

    return result;
}

#pragma mark - STKPXStrokeRenderer implementation

- (void)applyStrokeToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    if (strokes_)
    {
        for (id<STKPXStrokeRenderer> stroke in strokes_)
        {
            [stroke applyStrokeToPath:path withContext:context];
        }
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    strokes_ = nil;
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;

    if ([object isKindOfClass:[STKPXStrokeGroup class]])
    {
        STKPXStrokeGroup *that = object;

        result = [strokes_ isEqualToArray:that->strokes_];
    }

    return result;
}

@end
