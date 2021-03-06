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
//  STKPXStylesheet-Private.h
//  Pixate
//
//  Created by Kevin Lindsey on 2/5/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXRuleSet.h"
#import "STKPXStyleable.h"
#import "STKPXKeyframe.h"

@class STKPXMediaGroup;
@protocol STKPXMediaExpression;

/**
 *  A STKPXStylesheet typically corresponds to a single CSS file. Each stylesheet contains a list of rule sets defined
 *  within it.
 */
@interface STKPXStylesheet ()

/**
 *  A nonmutable array of rule sets that are contained within this stylesheet
 */
@property (readonly, nonatomic, strong) NSArray *ruleSets;

/**
 *  A nonmutable array of media groups that are contained within this stylesheet
 */
@property (readonly, nonatomic, strong) NSArray *mediaGroups;

/**
 *  The current media query that applies to any rule sets added to this stylesheet
 */
@property (nonatomic, strong) id<STKPXMediaExpression> activeMediaQuery;

/**
 *  Allocate and initialize a new stylesheet using the specified source and stylesheet origin
 *
 *  @param source The CSS source for this stylesheet
 *  @param origin The specificity origin for this stylesheet
 */
+ (id)styleSheetFromSource:(NSString *)source withOrigin:(STKPXStylesheetOrigin)origin;

/**
 *  Allocate and initialize a new styleheet for the specified path and stylesheet origin
 *
 *  @param filePath The string path to the stylesheet file
 *  @param origin The specificity origin for this stylesheet
 */
+ (id)styleSheetFromFilePath:(NSString *)filePath withOrigin:(STKPXStylesheetOrigin)origin;

/**
 *  A class-level getter returning the current application-level stylesheet. This value may be nil
 */
+ (STKPXStylesheet *)currentApplicationStylesheet;

/**
 *  A class-level getter returning the current user-level stylesheet. This value may be nil
 */
+ (STKPXStylesheet *)currentUserStylesheet;

/**
 *  A class-level getter returning the current view-level stylesheet. This value may be nil
 */
+ (STKPXStylesheet *)currentViewStylesheet;

/**
 *  Initialize a new stylesheet instance and set its stylesheet origin
 *
 *  @param origin The specificity origin for this stylesheet
 */
- (id)initWithOrigin:(STKPXStylesheetOrigin)origin;

/**
 *  Add a new rule set to this stylesheet
 *
 *  @param ruleSet The rule set to add. Nil values are ignored
 */
- (void)addRuleSet:(STKPXRuleSet *)ruleSet;

/**
 *  Register a namespace URI for a given prefix. If the prefix is nil or an empty string, then this method sets the
 *  default namespace URI.
 *
 *  @param uri The URI (as a string) for the namespace
 *  @param prefix The namespace prefix to associate with the namespace URI
 */
- (void)setURI:(NSString *)uri forNamespacePrefix:(NSString *)prefix;

/**
 *  Return the namespace URI for the specified prefix. If prefix is nil or an empty string, then the default namespace
 *  URI will be returned, if one has been defined
 *
 *  @param prefix The namespace prefix
 */
- (NSString *)namespaceForPrefix:(NSString *)prefix;

/**
 *  Return a list of rule sets whose selectors match against a specified element
 *
 *  @param element The element to match against
 */
- (NSArray *)ruleSetsMatchingStyleable:(id<STKPXStyleable>)element;

/**
 *  Add a keyframe animation to this stylesheet
 *
 *  @param keyframe The keyframe to add to the stylesheet
 */
- (void)addKeyframe:(STKPXKeyframe *)keyframe;

/**
 *  Retrieve the keyframe for the specified name. This may return nil
 *
 *  @param name The name of the keyframe
 */
- (STKPXKeyframe *)keyframeForName:(NSString *)name;

@end
