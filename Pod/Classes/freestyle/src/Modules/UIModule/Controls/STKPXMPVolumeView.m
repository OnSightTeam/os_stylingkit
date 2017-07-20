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
//  STKPXMPVolumeView.m
//  Pixate
//
//  Created by Paul Colton on 12/12/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXMPVolumeView.h"
#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXAnimationStyler.h"

@implementation STKPXMPVolumeView

+ (void)initialize
{
    if (self != STKPXMPVolumeView.class)
        return;
    
    [UIView registerDynamicSubclass:self
                           forClass:[STKPXMPVolumeView targetSuperclass]
                    withElementName:@"volume-view"];
}

+ (Class)targetSuperclass
{
	static Class targetSuperclass = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		targetSuperclass = NSClassFromString([[self description] substringFromIndex:2]);
	});
	return targetSuperclass;
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        stylers = @[
            STKPXTransformStyler.sharedInstance,
            STKPXLayoutStyler.sharedInstance,
            STKPXOpacityStyler.sharedInstance,
            STKPXAnimationStyler.sharedInstance,
         ];
    });
    
	return stylers;
}

- (NSDictionary *)viewStylersByProperty
{
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        map = [STKPXStyleUtils viewStylerPropertyMapForStyleable:self];
    });

    return map;
}

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
