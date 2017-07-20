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
//  STKPXTransitionStyler.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 3/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXTransitionStyler.h"

@implementation STKPXTransitionStyler

#pragma mark - Overrides

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
             @"transition" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 context.transitionInfos = declaration.transitionInfoList.mutableCopy;
             },
             @"transition-property" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *names = declaration.nameListValue;

                 for (NSUInteger i = 0; i < names.count; i++)
                 {
                     STKPXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSString *name = names[i];

                     info.animationName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                 }
             },
             @"transition-duration" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     STKPXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSNumber *time = timeValues[i];

                     info.animationDuration = time.floatValue;
                 }
             },
             @"transition-timing-function" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *timingFunctions = declaration.animationTimingFunctionList;

                 for (NSUInteger i = 0; i < timingFunctions.count; i++)
                 {
                     STKPXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSNumber *value = timingFunctions[i];

                     info.animationTimingFunction = (STKPXAnimationTimingFunction) value.intValue;
                 }
             },
             @"transition-delay" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                 NSArray *timeValues = declaration.secondsListValue;

                 for (NSUInteger i = 0; i < timeValues.count; i++)
                 {
                     STKPXAnimationInfo *info = [self transitionInfoAtIndex:i context:context];
                     NSNumber *time = timeValues[i];

                     info.animationDelay = time.floatValue;
                 }
             },
         };
    });

    return handlers;
}

- (STKPXAnimationInfo *)transitionInfoAtIndex:(NSUInteger)index context:(STKPXStylerContext *)context
{
    NSMutableArray *infos = context.transitionInfos;

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
    // remove invalid transition infos
    NSMutableArray *infos = context.transitionInfos;
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
    context.transitionInfos = infos;

    // continue with default behavior
    [super applyStylesWithContext:context];
}

@end
