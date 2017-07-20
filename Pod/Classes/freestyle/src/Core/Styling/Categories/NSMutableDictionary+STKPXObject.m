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
//  NSMutableDictionary+STKPXObject.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 3/26/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "NSMutableDictionary+STKPXObject.h"
#import "STKPXValue.h"

void STKPXForceLoadNSMutableDictionaryPXObject() {}

@implementation NSMutableDictionary (STKPXObject)

- (void)setNilableObject:(id)object forKey:(id<NSCopying>)key
{
    id nilableObject = (object == nil) ? [NSNull null] : object;

    self[key] = nilableObject;
}

- (void)setRect:(CGRect)rect forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&rect type:STKPXValueType_CGRect];

    self[key] = value;
}

- (void)setFloat:(CGFloat)floatValue forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&floatValue type:STKPXValueType_CGFloat];

    self[key] = value;
}

- (void)setColorRef:(CGColorRef)colorRef forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&colorRef type:STKPXValueType_CGColorRef];

    self[key] = value;
}

- (void)setSize:(CGSize)size forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&size type:STKPXValueType_CGSize];

    self[key] = value;
}

- (void)setBoolean:(BOOL)booleanValue forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&booleanValue type:STKPXValueType_Boolean];

    self[key] = value;
}

- (void)setTransform:(CGAffineTransform)transform forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&transform type:STKPXValueType_CGAffineTransform];

    self[key] = value;
}

- (void)setInsets:(UIEdgeInsets)insets forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&insets type:STKPXValueType_UIEdgeInsets];

    self[key] = value;
}

- (void)setLineBreakMode:(NSLineBreakMode)mode forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&mode type:STKPXValueType_NSLineBreakMode];

    self[key] = value;
}

- (void)setTextAlignment:(NSTextAlignment)alignment forKey:(id<NSCopying>)key
{
    STKPXValue *value = [[STKPXValue alloc] initWithBytes:&alignment type:STKPXValueType_NSTextAlignment];
    
    self[key] = value;
}
@end
