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
//  STKPXMediaGroup.h
//  Pixate
//
//  Created by Kevin Lindsey on 1/9/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXMediaExpression.h"
#import "STKPXStylesheet.h"
#import "STKPXRuleSet.h"

@interface STKPXMediaGroup : NSObject <STKPXMediaExpression>

/**
 *  A STKPXStylesheetOrigin enumeration value indicating the origin of this stylesheet. Origin values are used in
 *  specificity calculations.
 */
@property (readonly, nonatomic) STKPXStylesheetOrigin origin;

/**
 *  The media query associated with this grouping of rule sets
 */
@property (readonly, nonatomic) id<STKPXMediaExpression> query;

/**
 *  A nonmutable array of rule sets that are contained within this stylesheet
 */
@property (readonly, nonatomic, strong) NSArray *ruleSets;

/**
 *  Initialize a newly allocated instance
 *
 *  @param query The media query for this group
 *  @param origin The stylesheet origin for this group
 */
- (id)initWithQuery:(id<STKPXMediaExpression>)query origin:(STKPXStylesheetOrigin)origin;

/**
 *  Add a new rule set to this stylesheet
 *
 *  @param ruleSet The rule set to add. Nil values are ignored
 */
- (void)addRuleSet:(STKPXRuleSet *)ruleSet;

/**
 *  Return a list of rule sets that could apply to the given styleable
 *
 *  @param styleable The element to match
 */
- (NSArray *)ruleSetsForStyleable:(id<STKPXStyleable>)styleable;

@end
