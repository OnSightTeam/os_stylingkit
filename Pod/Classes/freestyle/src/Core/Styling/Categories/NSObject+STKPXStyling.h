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
//  NSObject+STKPXStyling.h
//  Pixate
//
//  Created by Paul Colton on 9/17/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXDeclaration.h"
#import "STKPXRuleSet.h"
#import "STKPXStylerContext.h"

@interface NSObject (STKPXStyling)

/*
 * Returns an array of stylers. Note that if this method does not exist, then styling is aborted for this object.
 */
- (NSArray *)viewStylers;

- (NSDictionary *)viewStylersByProperty;

- (void)updateStyleWithRuleSet:(STKPXRuleSet *)ruleSet context:(STKPXStylerContext *)context;

@end
