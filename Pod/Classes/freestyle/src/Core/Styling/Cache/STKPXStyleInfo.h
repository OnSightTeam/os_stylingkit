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
//  STKPXStyleInfo.h
//  Pixate
//
//  Created by Kevin Lindsey on 10/2/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXStyleable.h"

@interface STKPXStyleInfo : NSObject

@property (nonatomic, readonly) NSString *styleKey;
@property (nonatomic, readonly) NSArray *states;
@property (nonatomic) BOOL forceInvalidation;
@property (nonatomic) BOOL changeable;

+ (STKPXStyleInfo *)styleInfoForStyleable:(id<STKPXStyleable>)styleable;
+ (STKPXStyleInfo *)styleInfoForStyleable:(id<STKPXStyleable>)styleable checkPseudoClassFunction:(NSNumber**)checkPseudoClassFunction;
+ (void)setStyleInfo:(STKPXStyleInfo *)styleInfo withRuleSets:(NSArray *)ruleSets styleable:(id<STKPXStyleable>)styleable stateName:(NSString *)stateName;

- (id)initWithStyleKey:(NSString *)styleKey;

- (void)addDeclarations:(NSArray *)declarations forState:(NSString *)stateName;
- (void)addStylers:(NSSet *)stylers forState:(NSString *)stateName;
- (NSArray *)declarationsForState:(NSString *)stateName;
- (NSSet *)stylersForState:(NSString *)stateName;

- (void)applyToStyleable:(id<STKPXStyleable>)styleable;

@end
