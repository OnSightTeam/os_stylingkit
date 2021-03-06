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
//  STKPXValue.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 1/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PixateFreestyleConfiguration.h"
#import "STKPXBorderInfo.h"

typedef NS_ENUM(unsigned int, STKPXValueType) {
    STKPXValueType_CGRect,
    STKPXValueType_CGSize,
    STKPXValueType_CGFloat,
    STKPXValueType_CGAffineTransform,
    STKPXValueType_UIEdgeInsets,
    STKPXValueType_NSTextAlignment,
    STKPXValueType_NSLineBreakMode,
    STKPXValueType_Boolean,
    STKPXValueType_STKPXParseErrorDestination,
    STKPXValueType_STKPXCacheStylesType,
    STKPXValueType_UITextBorderStyle,
    STKPXValueType_CGColorRef,
    STKPXValueType_STKPXBorderStyle,
};

@interface STKPXValue : NSObject

@property (nonatomic, readonly) STKPXValueType type;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithBytes:(const void *)value type:(STKPXValueType)type NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly) CGRect CGRectValue;
@property (NS_NONATOMIC_IOSONLY, readonly) CGSize CGSizeValue;
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat CGFloatValue;
@property (NS_NONATOMIC_IOSONLY, readonly) CGAffineTransform CGAffineTransformValue;
@property (NS_NONATOMIC_IOSONLY, readonly) UIEdgeInsets UIEdgeInsetsValue;
@property (NS_NONATOMIC_IOSONLY, readonly) NSTextAlignment NSTextAlignmentValue;
@property (NS_NONATOMIC_IOSONLY, readonly) NSLineBreakMode NSLineBreakModeValue;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL BooleanValue;
@property (NS_NONATOMIC_IOSONLY, readonly) STKPXParseErrorDestination STKPXParseErrorDestinationValue;
@property (NS_NONATOMIC_IOSONLY, readonly) STKPXCacheStylesType STKPXCacheStylesTypeValue;
@property (NS_NONATOMIC_IOSONLY, readonly) UITextBorderStyle UITextBorderStyleValue;
@property (NS_NONATOMIC_IOSONLY, readonly) CGColorRef CGColorRefValue CF_RETURNS_NOT_RETAINED;
@property (NS_NONATOMIC_IOSONLY, readonly) STKPXBorderStyle STKPXBorderStyleValue;

@end
