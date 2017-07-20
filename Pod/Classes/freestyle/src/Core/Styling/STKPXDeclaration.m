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
//  STKPXDeclaration.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXDeclaration.h"
#import "STKPXStylesheetLexeme.h"
#import "STKPXStylesheetTokenType.h"
#import "STKPXValueParser.h"
#import "STKPXTransformParser.h"
#import "STKPXValue.h"
#import "STKPXStylerContext.h"

#define IsNotCachedType(T) ![cache_ isKindOfClass:[STKPXValue class]] || ((STKPXValue *)cache_).type != STKPXValueType_##T

@implementation STKPXDeclaration
{
    id cache_;
    NSUInteger hash_;
    NSString *source_;
    NSString *filename_;
}

static STKPXValueParser *PARSER;
static NSRegularExpression *ESCAPE_SEQUENCES;
static NSDictionary *ESCAPE_SEQUENCE_MAP;

#pragma mark - Static initializers

+ (void)initialize
{
    if (!ESCAPE_SEQUENCES)
    {
        NSError *error = NULL;

        ESCAPE_SEQUENCES = [NSRegularExpression regularExpressionWithPattern:@"\\\\."
                                                                     options:NSRegularExpressionDotMatchesLineSeparators
                                                                       error:&error];
    }
    if (!ESCAPE_SEQUENCE_MAP)
    {
        ESCAPE_SEQUENCE_MAP = @{
            @"\\t" : @"\t",
            @"\\r" : @"\r",
            @"\\n" : @"\n",
            @"\\f" : @"\f"
        };
    }

    if (!PARSER)
    {
        PARSER = [[STKPXValueParser alloc] init];
    }
}

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithName:@"<unknown>" value:nil];
}

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name value:nil];
}

- (instancetype)initWithName:(NSString *)name value:(NSString *)value
{
    if (self = [super init])
    {
        _name = name;
        cache_ = nil;

        [self setSource:value filename:nil lexemes:[STKPXValueParser lexemesForSource:value]];
    }

    return self;
}

#pragma mark - Setters

- (void)setSource:(NSString *)source filename:(NSString *)filename lexemes:(NSArray *)lexemes
{
    _lexemes = lexemes;
    source_ = source;
    filename_ = filename;

    hash_ = _name.hash;

    if (lexemes.count > 0)
    {
        STKPXStylesheetLexeme *firstLexeme = lexemes[0];
        NSUInteger firstOffset = firstLexeme.range.location;

        [_lexemes enumerateObjectsUsingBlock:^(STKPXStylesheetLexeme *lexeme, NSUInteger idx, BOOL *stop) {
            NSRange lexemeRange = lexeme.range;
            NSRange normalizedRange = NSMakeRange(lexemeRange.location - firstOffset, lexemeRange.length);

            hash_ = hash_ * 31 + [source substringWithRange:normalizedRange].hash;
        }];
    }
}

#pragma mark - Methods

- (CGAffineTransform)affineTransformValue
{
    if (IsNotCachedType(CGAffineTransform))
    {
        STKPXTransformParser *transformParser = [[STKPXTransformParser alloc] init];
        CGAffineTransform result = [transformParser parse:self.stringValue];

        cache_ = [[STKPXValue alloc] initWithBytes:&result type:STKPXValueType_CGAffineTransform];
    }

    return ((STKPXValue *)cache_).CGAffineTransformValue;
}

- (NSArray *)animationInfoList
{
    // TODO: cache
    return [self.parser parseAnimationInfos:_lexemes];
}

- (NSArray *)transitionInfoList
{
    // TODO: cache
    return [self.parser parseTransitionInfos:_lexemes];
}

- (NSArray *)animationDirectionList
{
    // TODO: cache
    return [self.parser parseAnimationDirectionList:_lexemes];
}

- (NSArray *)animationFillModeList
{
    // TODO: cache
    return [self.parser parseAnimationFillModeList:_lexemes];
}

- (NSArray *)animationPlayStateList
{
    // TODO: cache
    return [self.parser parseAnimationPlayStateList:_lexemes];
}

- (NSArray *)animationTimingFunctionList
{
    // TODO: cache
    return [self.parser parseAnimationTimingFunctionList:_lexemes];
}

- (BOOL)booleanValue
{
    if (IsNotCachedType(Boolean))
    {
        NSString *text = self.firstWord;
        BOOL result = ([@"yes" isEqualToString:text] || [@"true" isEqualToString:text]);

        cache_ = [[STKPXValue alloc] initWithBytes:&result type:STKPXValueType_Boolean];
    }

    return ((STKPXValue *) cache_).BooleanValue;
}

- (STKPXBorderInfo *)borderValue
{
    if (cache_ != [NSNull null] && ![cache_ isKindOfClass:[STKPXBorderInfo class]])
    {
        cache_ = [self.parser parseBorder:_lexemes];
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (NSArray *)borderRadiiList
{
    // TODO: cache
    return [self.parser parseBorderRadiusList:_lexemes];
}

- (STKPXBorderStyle)borderStyleValue
{
    if (IsNotCachedType(STKPXBorderStyle))
    {
        STKPXBorderStyle style = [self.parser parseBorderStyle:_lexemes];

        cache_ = [[STKPXValue alloc] initWithBytes:&style type:STKPXValueType_PXBorderStyle];
    }

    return ((STKPXValue *) cache_).STKPXBorderStyleValue;
}

- (NSArray *)borderStyleList
{
    // TODO: cache
    return [self.parser parseBorderStyleList:_lexemes];
}

- (STKPXCacheStylesType)cacheStylesTypeValue
{
    if (IsNotCachedType(STKPXCacheStylesType))
    {
        STKPXCacheStylesType type = STKPXCacheStylesTypeNone;
        NSArray *words = self.nameListValue;

        for (NSString *word in words)
        {
            if ([@"none" isEqualToString:word])
            {
                type = STKPXCacheStylesTypeNone;
            }
            else if ([@"auto" isEqualToString:word])
            {
                type |= STKPXCacheStylesTypeStyleOnce | STKPXCacheStylesTypeImages;
            }
            else if ([@"all" isEqualToString:word])
            {
                type |= STKPXCacheStylesTypeStyleOnce | STKPXCacheStylesTypeImages | STKPXCacheStylesTypeSave;
            }
            else if ([@"minimize-styling" isEqualToString:word])
            {
                type |= STKPXCacheStylesTypeStyleOnce;
            }
            else if ([@"cache-cells" isEqualToString:word])
            {
                type |= STKPXCacheStylesTypeSave;
            }
            else if ([@"cache-images" isEqualToString:word])
            {
                type |= STKPXCacheStylesTypeImages;
            }
        }

        cache_ = [[STKPXValue alloc] initWithBytes:&type type:STKPXValueType_PXCacheStylesType];
    }

    return ((STKPXValue *) cache_).STKPXCacheStylesTypeValue;
}

- (UIColor *)colorValue
{
    if (cache_ != [NSNull null] && ![cache_ isKindOfClass:[UIColor class]])
    {
        cache_ = [self.parser parseColor:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (NSString *)firstWord
{
    NSString *result = nil;

    if (_lexemes.count > 0)
    {
        STKPXStylesheetLexeme *lexeme = _lexemes[0];

        if ([lexeme.value isKindOfClass:[NSString class]])
        {
            result = lexeme.value;
            result = result.lowercaseString;
        }
    }

    return result;
}

- (CGFloat)floatValue
{
    if (IsNotCachedType(CGFloat))
    {
        CGFloat result = [self.parser parseFloat:_lexemes];

        cache_ = [[STKPXValue alloc] initWithBytes:&result type:STKPXValueType_CGFloat];
    }

    return ((STKPXValue *) cache_).CGFloatValue;
}

- (NSArray *)floatListValue
{
    // TODO: cache
    return [self.parser parseFloatList:_lexemes];
}

- (UIEdgeInsets)insetsValue
{
    if (IsNotCachedType(UIEdgeInsets))
    {
        UIEdgeInsets insets = [self.parser parseInsets:_lexemes];

        cache_ = [[STKPXValue alloc] initWithBytes:&insets type:STKPXValueType_UIEdgeInsets];
    }

    return ((STKPXValue *)cache_).UIEdgeInsetsValue;
}

- (STKPXDimension *)lengthValue
{
    if (![cache_ isKindOfClass:[STKPXDimension class]])
    {
        if (_lexemes.count > 0)
        {
            STKPXStylesheetLexeme *lexeme = _lexemes[0];

            if (lexeme.type == STKPXSS_LENGTH)
            {
                cache_ = lexeme.value;
            }
            else if (lexeme.type == STKPXSS_NUMBER)
            {
                NSNumber *number = lexeme.value;

                cache_ = [[STKPXDimension alloc] initWithNumber:number.floatValue withDimension:@"STKPX"];
            }
            // error
        }
    }

    return cache_;
}

// TODO: The return type if diff, but the enum order is the same...
- (NSLineBreakMode)lineBreakModeValue
{
    static NSDictionary *MAP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MAP = @{
            @"clip": @(NSLineBreakByClipping),
            @"ellipsis-head": @(NSLineBreakByTruncatingHead),
            @"ellipsis-middle": @(NSLineBreakByTruncatingMiddle),
            @"ellipsis": @(NSLineBreakByTruncatingMiddle),
            @"ellipsis-tail": @(NSLineBreakByTruncatingTail),
            @"word-wrap": @(NSLineBreakByWordWrapping),
            @"character-wrap": @(NSLineBreakByCharWrapping),
        };
    });

    if (IsNotCachedType(NSLineBreakMode))
    {
        NSLineBreakMode mode = NSLineBreakByTruncatingMiddle;
        NSString *text = self.firstWord;
        NSNumber *value = [MAP valueForKey:text];

        if (value)
        {
            mode = (NSLineBreakMode) value.intValue;
        }

        cache_ = [[STKPXValue alloc] initWithBytes:&mode type:STKPXValueType_NSLineBreakMode];
    }

    return ((STKPXValue *) cache_).NSLineBreakModeValue;
}

- (NSArray *)nameListValue
{
    // TODO: cache
    return [self.parser parseNameList:_lexemes];
}

- (STKPXOffsets *)offsetsValue
{
    if (cache_ != [NSNull null] && ![cache_ isKindOfClass:[STKPXOffsets class]])
    {
        cache_ = [self.parser parseOffsets:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (NSArray *)paintList
{
    // TODO: cache
    return [self.parser parsePaints:_lexemes];
}

- (id<STKPXPaint>)paintValue
{
    if (cache_ != [NSNull null] && ![cache_ conformsToProtocol:@protocol(STKPXPaint)])
    {
        cache_ = [self.parser parsePaint:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (STKSTKPXParseErrorDestination)parseErrorDestinationValue
{
    if (IsNotCachedType(STKSTKPXParseErrorDestination))
    {
        STKPXParseErrorDestination destination = STKPXParseErrorDestinationNone;
        NSString *text = self.firstWord;

        if ([@"console" isEqualToString:text])
        {
            destination = STKPXParseErrorDestinationConsole;
        }
#ifdef STKPX_LOGGING
        else if ([@"logger" isEqualToString:text])
        {
            destination = STKPXParseErrorDestination_Logger;
        }
#endif

        cache_ = [[STKPXValue alloc] initWithBytes:&destination type:STKPXValueType_STKPXParseErrorDestination];
    }

    return ((STKPXValue *) cache_).STKPXParseErrorDestinationValue;
}

- (CGFloat)secondsValue
{
    // TODO: cache
    return [self.parser parseSeconds:_lexemes];
}

- (NSArray *)secondsListValue
{
    // TODO: cache
    return [self.parser parseSecondsList:_lexemes];
}

- (CGSize)sizeValue
{
    if (IsNotCachedType(CGSize))
    {
        CGSize result = [self.parser parseSize:_lexemes];

        cache_ = [[STKPXValue alloc] initWithBytes:&result type:STKPXValueType_CGSize];
    }

    return ((STKPXValue *)cache_).CGSizeValue;
}

- (id<STKPXShadowPaint>)shadowValue
{
    if (cache_ != [NSNull null] && ![cache_ conformsToProtocol:@protocol(STKPXShadowPaint)])
    {
        cache_ = [self.parser parseShadow:_lexemes];

        if (cache_ == nil)
        {
            cache_ = [NSNull null];
        }
    }

    return (cache_ != [NSNull null]) ? cache_ : nil;
}

- (NSString *)stringValue
{
    if (![cache_ isKindOfClass:[NSString class]])
    {
        NSMutableArray *parts = [NSMutableArray arrayWithCapacity:_lexemes.count];

        for (STKPXStylesheetLexeme *lexeme in _lexemes)
        {
            if (lexeme.type == STKPXSS_STRING)
            {
                // grab raw value
                NSString *value = lexeme.value;

                // trim quotes
                NSString *content = [value substringWithRange:NSMakeRange(1, value.length - 2)];

                // replace escape sequences
                NSArray *matches = [ESCAPE_SEQUENCES matchesInString:content options:0 range:NSMakeRange(0, content.length)];

                for (NSTextCheckingResult *match in matches)
                {
                    NSRange matchRange = match.range;
                    NSString *replacementText = ESCAPE_SEQUENCE_MAP[[content substringWithRange:matchRange]];

                    if (!replacementText)
                    {
                        replacementText = [content substringWithRange:NSMakeRange(matchRange.location + 1, matchRange.length - 1)];
                    }

                    content = [content stringByReplacingCharactersInRange:matchRange withString:replacementText];
                }

                // append result
                [parts addObject:content];
            }
            else
            {
                [parts addObject:lexeme.value];
            }
        }

        // TODO: create another method to allow join string to be defined?
        cache_ = [parts componentsJoinedByString:@" "];
    }

    return cache_;
}

- (NSTextAlignment)textAlignmentValue
{
    static NSDictionary *MAP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MAP = @{
            @"left": @(NSTextAlignmentLeft),
            @"center": @(NSTextAlignmentCenter),
            @"right": @(NSTextAlignmentRight),
        };
    });

    if (IsNotCachedType(NSTextAlignment))
    {
        NSTextAlignment alignment = NSTextAlignmentCenter;
        NSString *text = self.firstWord;
        NSNumber *value = MAP[text];

        if (value)
        {
            alignment = (NSTextAlignment) value.intValue;
        }

        cache_ = [[STKPXValue alloc] initWithBytes:&alignment type:STKPXValueType_NSTextAlignment];
    }

    return ((STKPXValue *) cache_).NSTextAlignmentValue;
}

- (UITextBorderStyle)textBorderStyleValue
{
    static NSDictionary *MAP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MAP = @{
            @"line": @(UITextBorderStyleLine),
            @"bezel": @(UITextBorderStyleBezel),
            @"rounded-rect": @(UITextBorderStyleRoundedRect),
        };
    });

    if (IsNotCachedType(UITextBorderStyle))
    {
        UITextBorderStyle style = UITextBorderStyleNone;
        NSString *text = self.firstWord;
        NSNumber *value = MAP[text];

        if (value)
        {
            style = (UITextBorderStyle) value.intValue;
        }

        cache_ = [[STKPXValue alloc] initWithBytes:&style type:STKPXValueType_UITextBorderStyle];
    }

    return ((STKPXValue *) cache_).UITextBorderStyleValue;
}

- (NSString *)transformString:(NSString *)value
{
    NSString *text = self.firstWord;
    return [STKPXStylerContext transformString:value usingAttribute:text];
}

- (STKPXDimension *)letterSpacingValue
{
    STKPXDimension *result = nil;
    if (_lexemes.count > 0)
    {
        STKPXStylesheetLexeme *lexeme = _lexemes[0];
        
        if (lexeme.type == STKPXSS_LENGTH || lexeme.type == STKPXSS_EMS || lexeme.type == STKPXSS_PERCENTAGE)
        {
            result = lexeme.value;
        }
        else if (lexeme.type == STKPXSS_NUMBER)
        {
            NSNumber *number = lexeme.value;
            result = [[STKPXDimension alloc] initWithNumber:number.floatValue withDimension:@"STKPX"];
        }
        // error
    }
    return result;
}

- (NSURL *)URLValue
{
    // NOTE: When we generate URLs during the parse, we sometimes look for other files based on the specified file. It's
    // possible for a file to exist one time and not another, resulting in different URLs. We don't cache to catch these
    // cases.
    return [self.parser parseURL:_lexemes];
}

#pragma mark - Helpers

- (STKPXValueParser *)parser
{
    // TODO: pull from parser pool?
    PARSER.filename = filename_;

    return PARSER;
}

#pragma mark - Overrides

- (void)dealloc
{
    cache_ = nil;
    source_ = nil;
    _name = nil;
    _lexemes = nil;
}

- (NSString *)description
{
    if (self.important)
    {
        return [NSString stringWithFormat:@"%@: %@ !important;", self.name, self.stringValue];
    }
    else
    {
        return [NSString stringWithFormat:@"%@: %@;", self.name, self.stringValue];
    }
}

- (NSUInteger)hash
{
    return hash_;
}

@end
