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
//  STKPXAnimationStyler.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 3/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXAnimationStyler.h"
#import "STKPXAnimationInfo.h"
#import "STKPXAnimationPropertyHandler.h"
#import "STKPXKeyframeAnimation.h"

@implementation STKPXAnimationStyler

#pragma mark - Overrides

+ (STKPXAnimationStyler *)sharedInstance
{
	static __strong STKPXAnimationStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[STKPXAnimationStyler alloc] initWithCompletionBlock:nil];
	});

	return sharedInstance;
}

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
             @"animation" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 context.animationInfos = declaration.animationInfoList.mutableCopy;
             },
             @"animation-name" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *names = declaration.nameListValue;

                 for (NSUInteger i = 0; i < names.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSString *name = names[i];

                     info.animationName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                 }
             },
             @"animation-duration" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *time = timeValues[i];

                     info.animationDuration = time.floatValue;
                 }
             },
             @"animation-timing-function" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *timingFunctions = declaration.animationTimingFunctionList;

                 for (NSUInteger i = 0; i < timingFunctions.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = timingFunctions[i];

                     info.animationTimingFunction = (STKPXAnimationTimingFunction) value.intValue;
                 }
             },
             @"animation-iteration-count" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *counts = declaration.floatListValue;

                 for (NSUInteger i = 0; i < counts.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *count = counts[i];

                     info.animationIterationCount = (NSUInteger)count.floatValue;
                 }
             },
             @"animation-direction" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *directions = declaration.animationDirectionList;

                 for (NSUInteger i = 0; i < directions.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = directions[i];

                     info.animationDirection = (STKPXAnimationDirection) value.intValue;
                 }
             },
             @"animation-play-state" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *playStates = declaration.animationPlayStateList;

                 for (NSUInteger i = 0; i < playStates.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = playStates[i];

                     info.animationPlayState = (STKPXAnimationPlayState) value.intValue;
                 }
             },
             @"animation-delay" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *time = timeValues[i];

                     info.animationDelay = time.floatValue;
                 }
             },
             @"animation-fill-mode" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *fillModes = declaration.animationFillModeList;

                 for (NSUInteger i = 0; i < fillModes.count; i++)
                 {
                     STKPXAnimationInfo *info = [self animationInfoAtIndex:i context:context];
                     NSNumber *value = fillModes[i];

                     info.animationFillMode = (STKPXAnimationFillMode) value.intValue;
                 }
             },
        };
    });

    return handlers;
}

- (STKPXAnimationInfo *)animationInfoAtIndex:(NSUInteger)index context:(STKPXStylerContext *)context
{
    NSMutableArray *infos = context.animationInfos;

    if (infos == nil)
    {
        infos = [[NSMutableArray alloc] init];
        context.animationInfos = infos;
    }

    while (infos.count <= index)
    {
        [infos addObject:[[STKPXAnimationInfo alloc] init]];
    }

    return infos[index];
}

- (void)applyStylesWithContext:(STKPXStylerContext *)context
{
    // remove invalid animation infos
    NSMutableArray *infos = context.animationInfos;
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    STKPXAnimationInfo *currentSettings = [[STKPXAnimationInfo alloc] initWithCSSDefaults];

    for (STKPXAnimationInfo *info in infos)
    {
        if (info.animationName.length == 0)
        {
            // queue up to delete this unnamed animation
            [toRemove addObject:info];
        }
        else
        {
            // set any undefined values using the latest settings
            [info setUndefinedPropertiesWithAnimationInfo:currentSettings];
            currentSettings = info;
        }
    }

    [infos removeObjectsInArray:toRemove];
    context.animationInfos = infos;

    if (self.completionBlock)
    {
        // continue with default behavior
        [super applyStylesWithContext:context];
    }
    else
    {
        NSArray *animationInfos = context.animationInfos;
        NSArray *keyframes = [self keyframeAnimationsFromInfos:animationInfos styleable:context.styleable];

        // TODO: Can this be something else than UIView?
        UIView *view = (UIView *)context.styleable;

        [keyframes enumerateObjectsUsingBlock:^(CAKeyframeAnimation *keyframe, NSUInteger idx, BOOL *stop) {
            [view.layer addAnimation:keyframe forKey:nil];
        }];


        /*
        CATransition* trans = [CATransition animation];
        trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        trans.duration = 1;
        trans.type = kCATransitionFade;
        trans.removedOnCompletion = YES;
        trans.subtype = kCATransitionFromTop;

        [NSObject performBlock:^{
            [view.layer addAnimation:trans forKey:@"transition"];
            context.styleable.styleId = @"button1fun";
        } afterDelay:0.02];
         */
    }
}

- (NSDictionary *)defaultAnimationPropertyHandlers
{
    static NSDictionary *KEY_PATH_FROM_PROPERTY;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KEY_PATH_FROM_PROPERTY = @{
            @"left": [[STKPXAnimationPropertyHandler alloc] initWithKeyPath:@"position.x" block:STKPXAnimationPropertyHandler.FloatValueBlock],
            @"top": [[STKPXAnimationPropertyHandler alloc] initWithKeyPath:@"position.y" block:STKPXAnimationPropertyHandler.FloatValueBlock],
            @"opacity": [[STKPXAnimationPropertyHandler alloc] initWithKeyPath:@"opacity" block:STKPXAnimationPropertyHandler.FloatValueBlock],
            @"rotation": [[STKPXAnimationPropertyHandler alloc] initWithKeyPath:@"transform.rotation.z" block:STKPXAnimationPropertyHandler.FloatValueBlock],
            @"scale": [[STKPXAnimationPropertyHandler alloc] initWithKeyPath:@"transform.scale" block:STKPXAnimationPropertyHandler.FloatValueBlock],
        };
    });
    
    return KEY_PATH_FROM_PROPERTY;
}

- (NSArray *)keyframeAnimationsFromInfos:(NSArray *)infos styleable:(id<STKPXStyleable>)styleable
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableDictionary *propertyHandlers = [[NSMutableDictionary alloc] initWithDictionary:[self defaultAnimationPropertyHandlers]];

    // Add any additional user-provided property handlers
    if ([styleable respondsToSelector:@selector(animationPropertyHandlers)])
    {
        [propertyHandlers addEntriesFromDictionary:styleable.animationPropertyHandlers];
    }
    
    NSMutableDictionary *keyframes = [[NSMutableDictionary alloc] init];

    [infos enumerateObjectsUsingBlock:^(STKPXAnimationInfo *info, NSUInteger idx, BOOL *stop) {
        if (info.isValid)
        {
            STKPXKeyframe *keyframe = info.keyframe;

            if (keyframe)
            {
                [keyframe.blocks enumerateObjectsUsingBlock:^(STKPXKeyframeBlock *block, NSUInteger idx, BOOL *stop) {
                    [block.declarations enumerateObjectsUsingBlock:^(STKPXDeclaration *declaration, NSUInteger idx, BOOL *stop) {
                        STKPXAnimationPropertyHandler *propertyHandler = propertyHandlers[declaration.name];

                        if (propertyHandler != nil)
                        {
                            NSString *keyPath = propertyHandler.keyPath;
                            STKPXKeyframeAnimation *animation = keyframes[keyPath];

                            if (animation == nil)
                            {
                                animation = [[STKPXKeyframeAnimation alloc] init];
                                animation.keyPath = keyPath;
                                animation.duration = info.animationDuration;
                                animation.fillMode = info.animationFillMode;
                                animation.repeatCount = info.animationIterationCount;
                                animation.beginTime = info.animationDelay;

                                keyframes[keyPath] = animation;
                            }

                            // TODO: need to grab value type as is appropriate for the property being animated (via blocks?)
                            [animation addValue:[propertyHandler getValueFromDeclaration:declaration]];
                            [animation addKeyTime:block.offset];
                            [animation addTimingFunction:info.animationTimingFunction];
                        }
                    }];
                }];
            }
        }
    }];

    [keyframes enumerateKeysAndObjectsUsingBlock:^(NSString *key, STKPXKeyframeAnimation *animation, BOOL *stop) {
        CAKeyframeAnimation *keyframe = animation.caKeyframeAnimation;

        if (keyframe != nil)
        {
            [result addObject:keyframe];
        }
    }];

    return result;
}

@end
