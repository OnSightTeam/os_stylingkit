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
//  STKPXShadowGroup.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXShadowGroup.h"

@implementation STKPXShadowGroup
{
    NSMutableArray *shadows_;
}

#pragma mark - Getters

- (NSUInteger)count
{
    return shadows_.count;
}

- (NSArray *)shadows
{
    return shadows_;
}

#pragma mark - Methods

- (void)addShadowPaint:(id<STKPXShadowPaint>)shadow
{
    if (shadow)
    {
        if (shadows_ == nil)
        {
            shadows_ = [[NSMutableArray alloc] init];
        }

        [shadows_ addObject:shadow];
    }
}

- (void)applyInsetToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    for (id<STKPXShadowPaint> shadow in shadows_)
    {
        [shadow applyInsetToPath:path withContext:context];
    }
}

- (void)applyOutsetToPath:(CGPathRef)path withContext:(CGContextRef)context
{
    for (id<STKPXShadowPaint> shadow in shadows_)
    {
        [shadow applyOutsetToPath:path withContext:context];
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    shadows_ = nil;
}

@end
