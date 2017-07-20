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
//  STKPXTextShadowStyler.m
//  Pixate
//
//  Created by Kevin Lindsey on 5/20/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXTextShadowStyler.h"

@implementation STKPXTextShadowStyler

#pragma mark - Static Methods

+ (STKPXTextShadowStyler *)sharedInstance
{
	static __strong STKPXTextShadowStyler *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedInstance = [[STKPXTextShadowStyler alloc] init];
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
            @"text-shadow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                context.textShadow = declaration.shadowValue;
            }
        };
    });

    return handlers;
}

@end
