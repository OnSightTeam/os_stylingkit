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
//  STKPXForceLoadStylingCategories.m
//  Pixate
//
//  Created by Paul Colton on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXForceLoadStylingCategories.h"
#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "NSObject+STKPXStyling.h"
#import "NSObject+STKPXSubclass.h"
#import "NSObject+STKPXClass.h"
#import "NSArray+Reverse.h"
#import "NSMutableDictionary+STKPXObject.h"
#import "NSDictionary+STKPXCSSEncoding.h"
#import "NSDictionary+STKPXObject.h"

extern void STKPXForceLoadNSArrayReverse();
extern void STKPXForceLoadNSDictionaryPXCSSEncoding();
extern void STKPXForceLoadNSDictionaryPXObject();
extern void STKPXForceLoadNSMutableDictionaryPXObject();
extern void STKPXForceLoadNSObjectPXSubclass();
extern void STKPXForceLoadNSObjectPXSwizzle();
extern void STKPXForceLoadUIViewPXStyling();

@implementation STKPXForceLoadStylingCategories

+(void)forceLoad
{
    STKPXForceLoadNSArrayReverse();
    STKPXForceLoadNSDictionaryPXCSSEncoding();
    STKPXForceLoadNSDictionaryPXObject();
    STKPXForceLoadNSMutableDictionaryPXObject();
    STKPXForceLoadNSObjectPXSubclass();
    STKPXForceLoadNSObjectPXSwizzle();
    STKPXForceLoadUIViewPXStyling();
}

@end
