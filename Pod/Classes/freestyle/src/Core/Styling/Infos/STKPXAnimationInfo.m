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
//  STKPXAnimationInfo.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXAnimationInfo.h"

#import "STKPXStylesheet.h"
#import "STKPXStylesheet-Private.h"

@implementation STKPXAnimationInfo

#pragma mark - Initializers

/**
 *  Use this method to get undefined values (needed for parsing)
 */
- (instancetype)init
{
    if (self = [super init])
    {
        _animationName = nil;
        _animationDuration = CGFLOAT_MAX;
        _animationTimingFunction = STKPXAnimationTimingFunctionUndefined;
        _animationIterationCount = NSUIntegerMax;
        _animationDirection = STKPXAnimationDirectionUndefined;
        _animationPlayState = STKPXAnimationPlayStateUndefined;
        _animationDelay = CGFLOAT_MAX;
        _animationFillMode = STKPXAnimationFillModeUndefined;
    }

    return self;
}

/**
 *  Use this method to get CSS default values
 */
- (instancetype)initWithCSSDefaults
{
    if (self = [super init])
    {
        _animationName = nil;
        _animationDuration = 0.0f;
        _animationTimingFunction = STKPXAnimationTimingFunctionEase;
        _animationIterationCount = 0;
        _animationDirection = STKPXAnimationDirectionNormal;
        _animationPlayState = STKPXAnimationPlayStateRunning;
        _animationDelay = 0.0f;
        _animationFillMode = STKPXAnimationFillModeNone;
    }

    return self;
}

#pragma mark - Getters

- (STKPXKeyframe *)keyframe
{
    STKPXKeyframe *result = [[STKPXStylesheet currentViewStylesheet] keyframeForName:_animationName];

    if (result == nil)
    {
        result = [[STKPXStylesheet currentUserStylesheet] keyframeForName:_animationName];
    }

    if (result == nil)
    {
        result = [[STKPXStylesheet currentApplicationStylesheet] keyframeForName:_animationName];
    }

    return result;
}

-(BOOL)isValid
{
    return (
            _animationDuration != CGFLOAT_MAX
        &&  _animationTimingFunction != STKPXAnimationTimingFunctionUndefined
        &&  _animationIterationCount != NSUIntegerMax
        &&  _animationDirection != STKPXAnimationDirectionUndefined
        &&  _animationPlayState != STKPXAnimationPlayStateUndefined
        &&  _animationDelay != CGFLOAT_MAX
        &&  _animationFillMode != STKPXAnimationFillModeUndefined);

}

#pragma mark - Methods

- (void)setUndefinedPropertiesWithAnimationInfo:(STKPXAnimationInfo *)info
{
    // skip animationName

    if (_animationDuration == CGFLOAT_MAX)
    {
        _animationDuration = info.animationDuration;
    }
    if (_animationTimingFunction == STKPXAnimationTimingFunctionUndefined)
    {
        _animationTimingFunction = info.animationTimingFunction;
    }
    if (_animationIterationCount == NSUIntegerMax)
    {
        _animationIterationCount = info.animationIterationCount;
    }
    if (_animationDirection == STKPXAnimationDirectionUndefined)
    {
        _animationDirection = info.animationDirection;
    }
    if (_animationPlayState == STKPXAnimationPlayStateUndefined)
    {
        _animationPlayState = info.animationPlayState;
    }
    if (_animationDelay == CGFLOAT_MAX)
    {
        _animationDelay = info.animationDelay;
    }
    if (_animationFillMode == STKPXAnimationFillModeUndefined)
    {
        _animationFillMode = info.animationFillMode;
    }
}

@end
