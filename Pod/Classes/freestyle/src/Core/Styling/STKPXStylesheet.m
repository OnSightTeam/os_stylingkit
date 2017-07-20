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
//  STKPXStylesheet.m
//  Pixate
//
//  Modified by Anton Matosov on 12/19/15.
//  Created by Kevin Lindsey on 7/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXStylesheet.h"
#import "STKPXStylesheet-Private.h"
#import "STKPXSpecificity.h"
#import "STKPXStylesheetParser.h"
#import "STKPXFileWatcher.h"
#import "STKPXStyleUtils.h"
#import "STKPXMediaExpression.h"
#import "STKPXMediaGroup.h"
#import "PixateFreestyle.h"

//NSString *const STKPXStylesheetDidChangeNotification = @"kPXStylesheetDidChangeNotification";

static STKPXStylesheetParser *PARSER;

static STKPXStylesheet *currentApplicationStylesheet = nil;
static STKPXStylesheet *currentUserStylesheet = nil;
static STKPXStylesheet *currentViewStylesheet = nil;

@implementation STKPXStylesheet
{
    NSMutableArray *mediaGroups_;
    id<STKPXMediaExpression> activeMediaQuery_;
    STKPXMediaGroup *activeMediaGroup_;
    NSMutableDictionary *namespacePrefixMap_;
    NSMutableDictionary *keyframesByName_;
}

STK_DEFINE_CLASS_LOG_LEVEL

#pragma mark - Static initializers

+ (void)initialize
{
    // TODO: Use a parser pool since the parser is not thread safe
    if (PARSER == nil)
    {
        PARSER = [[STKPXStylesheetParser alloc] init];
    }
}

+ (instancetype)styleSheetFromSource:(NSString *)source withOrigin:(STKPXStylesheetOrigin)origin
{
    return [self styleSheetFromSource:source withOrigin:origin filename:nil];
}

+ (instancetype)styleSheetFromSource:(NSString *)source withOrigin:(STKPXStylesheetOrigin)origin filename:(NSString *)name
{
    STKPXStylesheet *result = nil;

    // TODO: maybe the following can be more intelligent and only remove cache entries that reference the stylesheet being replaced

    // clear style cache
    [PixateFreestyle clearStyleCache];

    if (source.length > 0)
    {
        result = [PARSER parse:source withOrigin:origin filename:name];
        result->_errors = PARSER.errors;
    }
    else
    {
        result = [[STKPXStylesheet alloc] initWithOrigin:origin];
    }

    // update configuration - !!! This needs to be done some other way, just don't know how yet
    [STKPXStyleUtils updateStyleForStyleable:PixateFreestyle.configuration];

    return result;
}

+ (instancetype)styleSheetFromFilePath:(NSString *)aFilePath withOrigin:(STKPXStylesheetOrigin)origin
{
    NSString* source = [NSString stringWithContentsOfFile:aFilePath encoding:NSUTF8StringEncoding error:NULL];

    return [self styleSheetFromSource:source withOrigin:origin filename:aFilePath];
}

+ (void)clearCache
{
    [[self currentApplicationStylesheet] clearCache];
    [[self currentUserStylesheet] clearCache];
    [[self currentViewStylesheet] clearCache];
}

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithOrigin:STKPXStylesheetOriginApplication];
}

- (instancetype)initWithOrigin:(STKPXStylesheetOrigin)anOrigin
{
    if (self = [super init])
    {
        self->_origin = anOrigin;
        // Set this new stylesheet as one of the three current sheets (i.e. App, User, View)
        [STKPXStylesheet assignCurrentStylesheet:self withOrigin:anOrigin];
    }

    return self;
}

- (void)clearCache
{
    for (STKPXMediaGroup *group in mediaGroups_)
        [group clearCache];
}

#pragma mark - Getters

- (NSArray *)ruleSets
{
    NSMutableArray *combined;

    for (STKPXMediaGroup *group in mediaGroups_)
    {
        if ([group matches])
        {
            if (!combined)
            {
                combined = [NSMutableArray array];
            }

            [combined addObjectsFromArray:group.ruleSets];
        }
    }

    return combined;
}

- (NSArray *)ruleSetsForStyleable:(id<STKPXStyleable>)styleable
{
    NSMutableArray *combined;

    for (STKPXMediaGroup *group in mediaGroups_)
    {
        if ([group matches])
        {
            if (!combined)
            {
                combined = [NSMutableArray array];
            }

            [combined addObjectsFromArray:[group ruleSetsForStyleable:styleable]];
        }
    }

    return combined;
}

- (NSArray *)mediaGroups
{
    return mediaGroups_;
}

+ (STKPXStylesheet *)currentApplicationStylesheet
{
	return currentApplicationStylesheet;
}

+ (STKPXStylesheet *)currentUserStylesheet
{
	return currentUserStylesheet;
}

+ (STKPXStylesheet *)currentViewStylesheet
{
	return currentViewStylesheet;
}

#pragma mark - Setters

- (void)setActiveMediaQuery:(id<STKPXMediaExpression>)activeMediaQuery
{
    // TODO: test for equivalence of active query? If they match, then do nothing
    activeMediaQuery_ = activeMediaQuery;
    activeMediaGroup_ = nil;
}

- (void)setMonitorChanges:(BOOL)state
{
    if(self.filePath)
    {
        if(state)
        {
            [[STKPXFileWatcher sharedInstance] watchFile:self.filePath handler:^{
                // reload file
                [STKPXStylesheet styleSheetFromFilePath:self.filePath withOrigin:self.origin];

                // update all views
                [PixateFreestyle updateStylesForAllViews];

            }];
        }
        else
        {
            // NO OP right now
        }
    }
}

#pragma mark - Methods

- (void)addRuleSet:(STKPXRuleSet *)ruleSet
{
    if (ruleSet)
    {
        if (!activeMediaGroup_)
        {
            activeMediaGroup_ = [[STKPXMediaGroup alloc] initWithQuery:activeMediaQuery_ origin:self.origin];

            [self addMediaGroup:activeMediaGroup_];
        }

        [activeMediaGroup_ addRuleSet:ruleSet];
    }
}

- (void)addMediaGroup:(STKPXMediaGroup *)mediaGroup
{
    if (mediaGroup)
    {
        if (!mediaGroups_)
        {
            mediaGroups_ = [NSMutableArray array];
        }

        [mediaGroups_ addObject:mediaGroup];
    }
}

- (NSArray *)ruleSetsMatchingStyleable:(id<STKPXStyleable>)element
{
    NSMutableArray *result = [NSMutableArray array];

    if (element)
    {
        NSArray *candidateRuleSets = [self ruleSetsForStyleable:element];
        DDLogDebug(@"%@ = %lu", [STKPXStyleUtils descriptionForStyleable:element], (unsigned long)candidateRuleSets.count);

        for (STKPXRuleSet *ruleSet in candidateRuleSets)
        {
            if ([ruleSet matches:element])
            {
                DDLogInfo(@"%@ matched\n%@", [STKPXStyleUtils descriptionForStyleable:element], ruleSet.description);

                [result addObject:ruleSet];
            }
        }
    }

    return result;
}

- (void)setURI:(NSString *)uri forNamespacePrefix:(NSString *)prefix
{
    if (uri)
    {
        if (prefix == nil)
        {
            prefix = @"";
        }

        if (namespacePrefixMap_ == nil)
        {
            namespacePrefixMap_ = [[NSMutableDictionary alloc] init];
        }

        namespacePrefixMap_[prefix] = uri;
    }
}

- (NSString *)namespaceForPrefix:(NSString *)prefix
{
    NSString *result = nil;

    if (namespacePrefixMap_)
    {
        if (prefix == nil)
        {
            prefix = @"";
        }

        result = namespacePrefixMap_[prefix];
    }

    return result;
}

- (void)addKeyframe:(STKPXKeyframe *)keyframe
{
    if (keyframe != nil)
    {
        if (keyframesByName_ == nil)
        {
            keyframesByName_ = [[NSMutableDictionary alloc] init];
        }

        keyframesByName_[keyframe.name] = keyframe;
    }
}

- (STKPXKeyframe *)keyframeForName:(NSString *)name
{
    return keyframesByName_[name];
}

#pragma mark - Static public methods

// none

#pragma mark - Static private methods

+ (void)assignCurrentStylesheet:(STKPXStylesheet *)sheet withOrigin:(STKPXStylesheetOrigin)anOrigin
{
    switch (anOrigin)
    {
        case STKPXStylesheetOriginApplication:
            currentApplicationStylesheet = sheet;
            break;

        case STKPXStylesheetOriginUser:
            currentUserStylesheet = sheet;
            break;

        case STKPXStylesheetOriginView:
            currentViewStylesheet = sheet;
            break;

        case STKPXStylesheetOriginInline:
            // this origin type should never be handled here, but in STKPXStyleController directly
            break;
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    activeMediaGroup_ = nil;
    activeMediaQuery_ = nil;
    mediaGroups_ = nil;
}

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray array];

    for (STKPXMediaGroup *mediaGroup in mediaGroups_)
    {
        [parts addObject:mediaGroup.description];
    }

    return [parts componentsJoinedByString:@"\n"];
}

@end
