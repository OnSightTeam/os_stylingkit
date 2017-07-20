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
//  STKPXAnimationInfo.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXKeyframe.h"

/**
 *  An enumeration indicating what type of timing function to use in an animation
 */
typedef NS_ENUM(int, STKPXAnimationTimingFunction)
{
    STKPXAnimationTimingFunctionUndefined = -1,
    STKPXAnimationTimingFunctionEase,          // ease [default]
    STKPXAnimationTimingFunctionLinear,        // linear
    STKPXAnimationTimingFunctionEaseIn,        // ease-in
    STKPXAnimationTimingFunctionEaseOut,       // ease-out
    STKPXAnimationTimingFunctionEaseInOut,     // ease-in-out
    STKPXAnimationTimingFunctionStepStart,     // step-start
    STKPXAnimationTimingFunctionStepEnd,       // step-end
                                            // steps(<integer>[, [ start | end ] ]?)
                                            // cubic-bezier(<number>, <number>, <number>, <number>)
};

/**
 *  An enumeration indicating the direction of an animation
 */
typedef NS_ENUM(int, STKPXAnimationDirection)
{
    STKPXAnimationDirectionUndefined = -1,
    STKPXAnimationDirectionNormal,             // normal [default]
    STKPXAnimationDirectionReverse,            // reverse
    STKPXAnimationDirectionAlternate,          // alternate
    STKPXAnimationDirectionAlternateReverse    // alternate-reverse
};

/**
 *  An enumeration indicating the current state of an animation
 */
typedef NS_ENUM(int, STKPXAnimationPlayState)
{
    STKPXAnimationPlayStateUndefined = -1,
    STKPXAnimationPlayStateRunning,            // running [default]
    STKPXAnimationPlayStatePaused              // paused
};

/**
 *  An enumeration indicating how an animation should fill its remaining time
 */
typedef NS_ENUM(int, STKPXAnimationFillMode)
{
    STKPXAnimationFillModeUndefined = -1,
    STKPXAnimationFillModeNone,                // none [default]
    STKPXAnimationFillModeForwards,            // forwards
    STKPXAnimationFillModeBackwards,           // backwards
    STKPXAnimationFillModeBoth                 // both
};

@interface STKPXAnimationInfo : NSObject

@property (nonatomic, strong) NSString *animationName;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) STKPXAnimationTimingFunction animationTimingFunction;
@property (nonatomic) NSUInteger animationIterationCount;
@property (nonatomic) STKPXAnimationDirection animationDirection;
@property (nonatomic) STKPXAnimationPlayState animationPlayState;
@property (nonatomic) CGFloat animationDelay;
@property (nonatomic) STKPXAnimationFillMode animationFillMode;

@property (nonatomic, strong, readonly) STKPXKeyframe *keyframe;
@property (nonatomic, readonly, getter = isValid) BOOL valid;

- (instancetype)initWithCSSDefaults;

- (void)setUndefinedPropertiesWithAnimationInfo:(STKPXAnimationInfo *)info;

@end
