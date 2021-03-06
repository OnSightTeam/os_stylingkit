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
//  STKPXSpecificity.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The STKPXSpecificityType enumeration defines a list of specificity levels for rule sets based on the rule sets
 *  selector
 */
typedef NS_ENUM(unsigned int, STKPXSpecificityType)
{
    kSpecificityTypeOrigin,
    kSpecificityTypeId,
    kSpecificityTypeClassOrAttribute,
    kSpecificityTypeElement
};

/**
 *  A STKPXSpecificity represents an order lists of specificities based on specificity type. Instances of this class are
 *  used to determine the specificity of declarations in order to derive a list of declarations to apply given a set of
 *  rule sets being applied to a given element.
 */
@interface STKPXSpecificity : NSObject

/**
 *  Compare the current specificity to another, returning a CFComparisonResult. This is used to sort arrays of
 *  items with specificity, typically STKPXRuleSets
 *
 *  @param specificity The other STKPXSpecificity to compare against
 */
- (NSComparisonResult)compareSpecificity:(STKPXSpecificity *)specificity;

/**
 *  Increase the specificity counter for the given specificity type
 *
 *  @param specificity The specificity type being incremented
 */
- (void)incrementSpecifity:(STKPXSpecificityType)specificity;

/**
 *  Set the specificity counter for a given specificity type
 *
 *  @param specificity The specificity type being set
 *  @param value The new value
 */
- (void)setSpecificity:(STKPXSpecificityType)specificity toValue:(int)value;

@end
