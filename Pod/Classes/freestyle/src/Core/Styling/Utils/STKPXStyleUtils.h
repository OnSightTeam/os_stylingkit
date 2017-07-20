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
//  STKPXStyleUtils.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXStyleable.h"

typedef struct {
    NSInteger childrenCount;
    NSInteger childrenIndex;
    NSInteger childrenOfTypeCount;
    NSInteger childrenOfTypeIndex;
} STKPXStyleableChildrenInfo;

@interface STKPXStyleUtils : NSObject

+ (NSArray *)elementChildrenOfStyleable:(id<STKPXStyleable>)styleable;

+ (NSInteger)childCountForStyleable:(id<STKPXStyleable>)styleable;
+ (STKPXStyleableChildrenInfo *)childrenInfoForStyleable:(id<STKPXStyleable>)styleable;

+ (NSString *)descriptionForStyleable:(id<STKPXStyleable>)styleable;
+ (NSString *)selectorFromStyleable:(id<STKPXStyleable>)styleable;
+ (NSString *)styleKeyFromStyleable:(id<STKPXStyleable>)styleable;

+ (void)enumerateStyleableAndDescendants:(id<STKPXStyleable>)styleable usingBlock:(void (^)(id obj, BOOL *stop, BOOL *stopDescending))block;
+ (void)enumerateStyleableDescendants:(id<STKPXStyleable>)styleable usingBlock:(void (^)(id obj, BOOL *stop, BOOL *stopDescending))block;

+ (NSDictionary *)viewStylerPropertyMapForStyleable:(id<STKPXStyleable>)styleable;
+ (NSMutableArray *)matchingRuleSetsForStyleable:(id<STKPXStyleable>)styleable;
+ (NSArray *)filterRuleSets:(NSArray *)ruleSets forStyleable:(id<STKPXStyleable>)styleable byState:(NSString *)stateName;
+ (NSArray *)filterRuleSets:(NSArray *)ruleSets byPseudoElement:(NSString *)pseudoElement;

+ (BOOL)stylesOfStyleable:(id<STKPXStyleable>)styleable matchDeclarations:(NSArray *)declarations state:(NSString *)state;
+ (void)invalidateStyleable:(id<STKPXStyleable>)styleable;
+ (void)invalidateStyleableAndDescendants:(id<STKPXStyleable>)styleable;
+ (NSUInteger)hashValueForStyleable:(id<STKPXStyleable>)styleable state:(NSString *)state;

+ (void)setItemIndex:(NSIndexPath *)index forObject:(NSObject *)object;
+ (NSIndexPath *)itemIndexForObject:(NSObject *)object;

+ (void)setViewDelegate:(id)delegate forObject:(id)object;
+ (id)viewDelegateForObject:(id)object;

/**
 *  Style the specified styleable
 *
 *  @param styleable The styleable to update
 */
+ (void)updateStyleForStyleable:(id<STKPXStyleable>)styleable;

/**
 *  Force an update of the specified styleable. If the recurse flag is true, all descendants of the styleable will be
 *  updated as well.
 *
 *  @param styleable The styleable to update
 *  @param recurse A boolean indicating if descendants should be updated as well
 */
+ (void)updateStylesForStyleable:(id<STKPXStyleable>)styleable andDescendants:(BOOL)recurse;

/**
 * Waits until a new cell is positioned in a tableview or collectionview before updating.
 */
+ (void)updateCellStyleWhenReady:(UIView *)view;
+ (void)updateCellStyleNonRecursiveWhenReady:(UIView *)view;

@end
