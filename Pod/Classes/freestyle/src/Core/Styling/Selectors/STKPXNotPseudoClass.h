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
//  STKPXNotPseudoClass.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXSelector.h"

/**
 *  A STKPXNotSelector negates a given selector expression
 */
@interface STKPXNotPseudoClass : NSObject <STKPXSelector>

/**
 *  The expression to be negated during matching. Or, said another way, the expression that must fail for this selector
 *  to succeed during matching.
 */
@property (nonatomic, strong) id<STKPXSelector> expression;

/**
 *  Initializer a new instance with the specified expression
 *
 *  @param expression The STKPXElementMatcher expression to negate
 */
- (id)initWithExpression:(id<STKPXSelector>)expression;

@end
