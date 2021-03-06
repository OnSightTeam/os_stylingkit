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
//  STKPXOpacityStyler.m
//  Pixate
//
//  Created by Paul Colton on 10/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXOpacityStyler.h"

@implementation STKPXOpacityStyler

#pragma mark - Static Methods

+ (STKPXOpacityStyler *)sharedInstance
{
    static __strong STKPXOpacityStyler *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[STKPXOpacityStyler alloc]
            initWithCompletionBlock:^(id <STKPXStyleable> view, STKPXOpacityStyler *styler, STKPXStylerContext *context)
            {
                if ([view isKindOfClass:NSClassFromString(@"UIView")])
                {
                    ((UIView *)view).alpha = context.opacity;
                }
            }];
    });

    return sharedInstance;
}

#pragma mark - Methods

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        handlers = @{
            @"opacity" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context)
            {
                context.opacity = declaration.floatValue;
            }
        };
    });

    return handlers;
}

@end
