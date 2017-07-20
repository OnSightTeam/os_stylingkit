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
//  STKPXValue.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 1/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXValue.h"

@implementation STKPXValue
{
    NSValue *value_;
}

- (instancetype)initWithBytes:(const void *)value type:(STKPXValueType)type
{
    if (self = [super init])
    {
        _type = type;

        switch (type)
        {
            case STKPXValueType_CGRect:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGRect)];
                break;

            case STKPXValueType_CGSize:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGSize)];
                break;

            case STKPXValueType_CGFloat:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGFloat)];
                break;

            case STKPXValueType_CGAffineTransform:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGAffineTransform)];
                break;

            case STKPXValueType_UIEdgeInsets:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(UIEdgeInsets)];
                break;

            case STKPXValueType_NSTextAlignment:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(NSTextAlignment)];
                break;

            case STKPXValueType_NSLineBreakMode:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(NSLineBreakMode)];
                break;

            case STKPXValueType_Boolean:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(BOOL)];
                break;

            case STKPXValueType_STKPXParseErrorDestination:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(STKPXParseErrorDestination)];
                break;

            case STKPXValueType_STKPXCacheStylesType:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(STKPXCacheStylesType)];
                break;

            case STKPXValueType_UITextBorderStyle:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(UITextBorderStyle)];
                break;

            case STKPXValueType_CGColorRef:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(CGColorRef)];
                break;

            case STKPXValueType_STKPXBorderStyle:
                value_ = [[NSValue alloc] initWithBytes:value objCType:@encode(STKPXBorderStyle)];
                break;

            default:
                break;
        }
    }

    return self;
}

- (CGRect)CGRectValue
{
    return (_type == STKPXValueType_CGRect) ? [value_ CGRectValue] : CGRectZero;
}

- (CGSize)CGSizeValue
{
    return (_type == STKPXValueType_CGSize) ? [value_ CGSizeValue] : CGSizeZero;
}

- (CGFloat)CGFloatValue
{
    CGFloat result = 0.0f;

    if (_type == STKPXValueType_CGFloat)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (CGAffineTransform)CGAffineTransformValue
{
    CGAffineTransform result = CGAffineTransformIdentity;

    if (_type == STKPXValueType_CGAffineTransform)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (UIEdgeInsets)UIEdgeInsetsValue
{
    UIEdgeInsets result = UIEdgeInsetsZero;

    if (_type == STKPXValueType_UIEdgeInsets)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (NSTextAlignment)NSTextAlignmentValue
{
    NSTextAlignment result = NSTextAlignmentCenter;

    if (_type == STKPXValueType_NSTextAlignment)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (NSLineBreakMode)NSLineBreakModeValue
{
    NSLineBreakMode result = NSLineBreakByTruncatingMiddle;

    if (_type == STKPXValueType_NSLineBreakMode)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (BOOL)BooleanValue
{
    BOOL result = NO;

    if (_type == STKPXValueType_Boolean)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (STKPXParseErrorDestination)STKPXParseErrorDestinationValue
{
    STKPXParseErrorDestination result = STKPXParseErrorDestinationNone;

    if (_type == STKPXValueType_STKPXParseErrorDestination)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (STKPXCacheStylesType)STKPXCacheStylesTypeValue
{
    STKPXCacheStylesType result = STKPXCacheStylesTypeNone;

    if (_type == STKPXValueType_STKPXCacheStylesType)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (UITextBorderStyle)UITextBorderStyleValue
{
    UITextBorderStyle result = UITextBorderStyleNone;

    if (_type == STKPXValueType_UITextBorderStyle)
    {
        [value_ getValue:&result];
    }

    return result;
}

- (CGColorRef)CGColorRefValue
{
    CGColorRef result;

    if (_type == STKPXValueType_CGColorRef)
    {
        [value_ getValue:&result];
    }
    else
    {
        // TODO: Is this a reasonable default value?
        result = [UIColor blackColor].CGColor;
    }

    return result;
}

- (STKPXBorderStyle)STKPXBorderStyleValue
{
    STKPXBorderStyle result = STKPXBorderStyleNone;

    if (_type == STKPXValueType_STKPXBorderStyle)
    {
        [value_ getValue:&result];
    }

    return result;
}

@end
