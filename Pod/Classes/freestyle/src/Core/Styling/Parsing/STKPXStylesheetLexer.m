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
//  STKPXSSLexer.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXStylesheetLexer.h"
#import "STKPXStylesheetTokenType.h"
#import "STKPXPatternMatcher.h"
#import "STKPXCharacterMatcher.h"
#import "STKPXNumberMatcher.h"
#import "STKPXWordMatcher.h"
#import "NSMutableArray+StackAdditions.h"
#import "STKPXURLMatcher.h"

@interface LexerState : NSObject
@property (nonatomic, strong, readonly) NSString *source;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) NSUInteger blockDepth;
@property (nonatomic, strong, readonly) NSMutableArray *lexemeStack;
@end

@implementation LexerState
- (instancetype)initWithSource:(NSString *)source offset:(NSUInteger)offset blockDepth:(NSUInteger)blockDepth lexemeStack:(NSMutableArray *)lexemeStack
{
    if (self = [super init])
    {
        _source = source;
        _offset = offset;
        _blockDepth = blockDepth;
        _lexemeStack = lexemeStack;
    }

    return self;
}

-(void)dealloc
{
    _source = nil;
    _lexemeStack = nil;
}
@end

@implementation STKPXStylesheetLexer
{
    NSArray *tokens_;
    NSUInteger offset_;
    NSUInteger blockDepth_;
    NSMutableArray *lexemeStack_;
    NSMutableArray *stateStack_;
}

#pragma mark - Initializers

- (instancetype)init
{
    if (self = [super init])
    {
        // create tokens
        NSMutableArray *tokenList = [NSMutableArray array];

        // whitespace
        [tokenList addObject: [[STKPXPatternMatcher alloc] initWithType:STKPXSS_WHITESPACE
                                                     withPatternString:@"^[ \\t\\r\\n]+"]];
        [tokenList addObject: [[STKPXPatternMatcher alloc] initWithType:STKPXSS_WHITESPACE
                                                    withPatternString:@"^/\\*(?:.|[\n\r])*?\\*/"]];

        // pseudo-classes
        NSDictionary *pseudoClassMap = @{
            @":not(": @(STKPXSS_NOT_PSEUDO_CLASS),
            @":link": @(STKPXSS_LINK_PSEUDO_CLASS),
            @":visited": @(STKPXSS_VISITED_PSEUDO_CLASS),
            @":hover": @(STKPXSS_HOVER_PSEUDO_CLASS),
            @":active": @(STKPXSS_ACTIVE_PSEUDO_CLASS),
            @":focus": @(STKPXSS_FOCUS_PSEUDO_CLASS),
            @":target": @(STKPXSS_TARGET_PSEUDO_CLASS),
            @":lang(": @(STKPXSS_LANG_PSEUDO_CLASS),
            @":enabled": @(STKPXSS_ENABLED_PSEUDO_CLASS),
            @":checked": @(STKPXSS_CHECKED_PSEUDO_CLASS),
            @":indeterminate": @(STKPXSS_INDETERMINATE_PSEUDO_CLASS),
            @":root": @(STKPXSS_ROOT_PSEUDO_CLASS),
            @":nth-child(": @(STKPXSS_NTH_CHILD_PSEUDO_CLASS),
            @":nth-last-child(": @(STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS),
            @":nth-of-type(": @(STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS),
            @":nth-last-of-type(": @(STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS),
            @":first-child": @(STKPXSS_FIRST_CHILD_PSEUDO_CLASS),
            @":last-child": @(STKPXSS_LAST_CHILD_PSEUDO_CLASS),
            @":first-of-type": @(STKPXSS_FIRST_OF_TYPE_PSEUDO_CLASS),
            @":last-of-type": @(STKPXSS_LAST_OF_TYPE_PSEUDO_CLASS),
            @":only-child": @(STKPXSS_ONLY_CHILD_PSEUDO_CLASS),
            @":only-of-type": @(STKPXSS_ONLY_OF_TYPE_PSEUDO_CLASS),
            @":empty": @(STKPXSS_EMPTY_PSEUDO_CLASS),
            @":first-line": @(STKPXSS_FIRST_LINE_PSEUDO_ELEMENT),
            @":first-letter": @(STKPXSS_FIRST_LETTER_PSEUDO_ELEMENT),
            @":before": @(STKPXSS_BEFORE_PSEUDO_ELEMENT),
            @":after": @(STKPXSS_AFTER_PSEUDO_ELEMENT),
        };
        [tokenList addObject:[[STKPXWordMatcher alloc] initWithDictionary:pseudoClassMap usingSymbols:YES]];

        // functions
        NSDictionary *functionMap = @{
            @"linear-gradient(": @(STKPXSS_LINEAR_GRADIENT),
            @"radial-gradient(": @(STKPXSS_RADIAL_GRADIENT),
            @"hsb(": @(STKPXSS_HSB),
            @"hsba(": @(STKPXSS_HSBA),
            @"hsl(": @(STKPXSS_HSL),
            @"hsla(": @(STKPXSS_HSLA),
            @"rgb(": @(STKPXSS_RGB),
            @"rgba(": @(STKPXSS_RGBA)
        };
        [tokenList addObject:[[STKPXWordMatcher alloc] initWithDictionary:functionMap usingSymbols:YES]];

        // urls
        [tokenList addObject:[[STKPXURLMatcher alloc] initWithType:STKPXSS_URL]];

        // nth
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_NTH withPatternString:@"^[-+]?\\d*[nN]\\b"]];

        // dimensions
        NSDictionary *unitMap = @{
            @"em": @(STKPXSS_EMS),
            @"ex": @(STKPXSS_EXS),
            @"STKPX": @(STKPXSS_LENGTH),
            @"dpx": @(STKPXSS_LENGTH),
            @"cm": @(STKPXSS_LENGTH),
            @"mm": @(STKPXSS_LENGTH),
            @"in": @(STKPXSS_LENGTH),
            @"pt": @(STKPXSS_LENGTH),
            @"pc": @(STKPXSS_LENGTH),
            @"deg": @(STKPXSS_ANGLE),
            @"rad": @(STKPXSS_ANGLE),
            @"grad": @(STKPXSS_ANGLE),
            @"ms": @(STKPXSS_TIME),
            @"s": @(STKPXSS_TIME),
            @"Hz": @(STKPXSS_FREQUENCY),
            @"kHz": @(STKPXSS_FREQUENCY),
            @"%": @(STKPXSS_PERCENTAGE),
            @"[-a-zA-Z_][-a-zA-Z0-9_]*": @(STKPXSS_DIMENSION)
        };
        [tokenList addObject:[[STKPXNumberMatcher alloc] initWithType:STKPXSS_NUMBER withDictionary:unitMap withUnknownType:STKPXSS_DIMENSION]];

        // hex colors
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_HEX_COLOR withPatternString:@"^#(?:[a-fA-F0-9]{8}|[a-fA-F0-9]{6}|[a-fA-F0-9]{4}|[a-fA-F0-9]{3})\\b"]];

        // various identifiers
        NSDictionary *keywordMap = @{
            @"@keyframes" : @(STKPXSS_KEYFRAMES),
            @"@namespace" : @(STKPXSS_NAMESPACE),
            @"@import" : @(STKPXSS_IMPORT),
            @"@media" : @(STKPXSS_MEDIA),
            @"@font-face": @(STKPXSS_FONT_FACE),
            @"and" : @(STKPXSS_AND),
        };
        [tokenList addObject:[[STKPXWordMatcher alloc] initWithDictionary:keywordMap]];
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_CLASS withPatternString:@"^\\.(?:[-a-zA-Z_]|\\\\[^\\r\\n\\f0-9a-f])(?:[-a-zA-Z0-9_]|\\\\[^\\r\\n\\f0-9a-f])*"]];
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_ID withPatternString:@"^#(?:[-a-zA-Z_]|\\\\[^\\r\\n\\f0-9a-f])(?:[-a-zA-Z0-9_]|\\\\[^\\r\\n\\f0-9a-f])*"]];
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_IDENTIFIER withPatternString:@"^(?:[-a-zA-Z_]|\\\\[^\\r\\n\\f0-9a-f])(?:[-a-zA-Z0-9_]|\\\\[^\\r\\n\\f0-9a-f])*"]];
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_IMPORTANT withPatternString:@"^!\\s*important\\b"]];

        // strings
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_STRING withPatternString:@"^\"(?:[^\"\\\\\\r\\n\\f]|\\\\[^\\r\\n\\f])*\""]];
        [tokenList addObject:[[STKPXPatternMatcher alloc] initWithType:STKPXSS_STRING withPatternString:@"^'(?:[^'\\\\\\r\\n\\f]|\\\\[^\\r\\n\\f])*'"]];

        // multi-character operators
        NSDictionary *operatorMap = @{
            @"::": @(STKPXSS_DOUBLE_COLON),
            @"^=": @(STKPXSS_STARTS_WITH),
            @"$=": @(STKPXSS_ENDS_WITH),
            @"*=": @(STKPXSS_CONTAINS),
            @"~=": @(STKPXSS_LIST_CONTAINS),
            @"|=": @(STKPXSS_EQUALS_WITH_HYPHEN),
        };
        [tokenList addObject:[[STKPXWordMatcher alloc] initWithDictionary:operatorMap usingSymbols:YES]];

        // single-character operators
        NSString *operators = @"{}()[];>+~*=:,|/";
        NSArray *operatorTypes = @[
            @(STKPXSS_LCURLY),
            @(STKPXSS_RCURLY),
            @(STKPXSS_LPAREN),
            @(STKPXSS_RPAREN),
            @(STKPXSS_LBRACKET),
            @(STKPXSS_RBRACKET),
            @(STKPXSS_SEMICOLON),
            @(STKPXSS_GREATER_THAN),
            @(STKPXSS_PLUS),
            @(STKPXSS_TILDE),
            @(STKPXSS_STAR),
            @(STKPXSS_EQUAL),
            @(STKPXSS_COLON),
            @(STKPXSS_COMMA),
            @(STKPXSS_PIPE),
            @(STKPXSS_SLASH)
        ];
        [tokenList addObject:[[STKPXCharacterMatcher alloc] initWithCharactersInString:operators withTypes:operatorTypes]];

        tokens_ = tokenList;
    }

    return self;
}

- (instancetype)initWithString:(NSString *)text
{
    if (self = [self init])
    {
        self.source = text;
    }

    return self;
}

#pragma mark - Setter

- (void)setSource:(NSString *)aSource
{
    _source = aSource;
    offset_ = 0;
    blockDepth_ = 0;
    lexemeStack_ = nil;
}

#pragma mark - Methods

- (void)pushLexeme:(STKPXStylesheetLexeme *)lexeme
{
    if (lexeme)
    {
        if (lexemeStack_ == nil)
        {
            lexemeStack_ = [[NSMutableArray alloc] init];
        }

        [lexemeStack_ push:lexeme];

        // reverse block depth settings
        if (lexeme.type == STKPXSS_LCURLY)
        {
            [self decreaseNesting];
        }
        else if (lexeme.type == STKPXSS_RCURLY)
        {
            [self increaseNesting];
        }
    }
}

- (void)pushSource:(NSString *)source
{
    if (stateStack_ == nil)
    {
        stateStack_ = [[NSMutableArray alloc] init];
    }

    LexerState *state = [[LexerState alloc] initWithSource:_source offset:offset_ blockDepth:blockDepth_ lexemeStack:lexemeStack_];

    [stateStack_ push:state];

    self.source = source;
}

- (void)popSource
{
    if (stateStack_.count > 0)
    {
        LexerState *state = [stateStack_ pop];

        _source = state.source;
        offset_ = state.offset;
        blockDepth_ = state.blockDepth;
        lexemeStack_ = state.lexemeStack;

        // fire delegate
        if (_delegate)
        {
            if ([_delegate respondsToSelector:@selector(lexerDidPopSource)])
            {
                [_delegate lexerDidPopSource];
            }
        }
    }
}

- (void)increaseNesting
{
    blockDepth_++;
}

- (void)decreaseNesting
{
    blockDepth_--;
}

- (STKPXStylesheetLexeme *)nextLexeme
{
    STKPXStylesheetLexeme *result = nil;

    if (lexemeStack_.count > 0)
    {
        result = [lexemeStack_ pop];
    }
    else if (_source)
    {
        NSUInteger length = _source.length;
        BOOL followsWhitespace = NO;

        // loop until we find a valid lexeme or the end of the string
        while (offset_ < length)
        {
            NSRange range = NSMakeRange(offset_, length - offset_);
            STKPXStylesheetLexeme *candidate = nil;

            for (id<STKPXLexemeCreator> creator in tokens_)
            {
                STKPXStylesheetLexeme *lexeme = [creator createLexemeWithString:_source withRange:range];

                if (lexeme)
                {
                    NSRange lexemeRange = lexeme.range;

                    offset_ = lexemeRange.location + lexemeRange.length;
                    candidate = lexeme;

                    if (followsWhitespace)
                    {
                        [lexeme setFlag:STKPXLexemeFlagFollowsWhitespace];
                    }
                    break;
                }
            }

            // skip whitespace
            if (!candidate || candidate.type != STKPXSS_WHITESPACE)
            {
                result = candidate;
                break;
            }
            else
            {
                followsWhitespace = YES;
            }
        }

        // possibly create an error token
        if (!result && offset_ < length)
        {
            NSRange range = NSMakeRange(offset_, 1);
            result = [STKPXStylesheetLexeme lexemeWithType:STKPXSS_ERROR withRange:range withValue:[_source substringWithRange:range]];

            if (followsWhitespace)
            {
                [result setFlag:STKPXLexemeFlagFollowsWhitespace];
            }

            offset_++;
        }
    }

    if (result)
    {
        BOOL followsWhitespace = [result flagIsSet:STKPXLexemeFlagFollowsWhitespace];

        if (blockDepth_ == 0 && result.type == STKPXSS_HEX_COLOR)
        {
            // fix-up colors to be ids outside of declaration blocks
            result = [STKPXStylesheetLexeme lexemeWithType:STKPXSS_ID withRange:result.range withValue:result.value];

            if (followsWhitespace)
            {
                [result setFlag:STKPXLexemeFlagFollowsWhitespace];
            }
        }

        switch (result.type)
        {
            case STKPXSS_LCURLY:
                [self increaseNesting];
                break;

            case STKPXSS_RCURLY:
                [self decreaseNesting];
                break;

            case STKPXSS_ID:
            case STKPXSS_CLASS:
            case STKPXSS_IDENTIFIER:
            {
                NSString *stringValue = result.value;

                if ([stringValue rangeOfString:@"\\"].location != NSNotFound)
                {
                    // simply drop slash, for now
                    stringValue = [stringValue stringByReplacingOccurrencesOfString:@"\\" withString:@""];

                    result = [STKPXStylesheetLexeme lexemeWithType:result.type withRange:result.range withValue:stringValue];

                    if (followsWhitespace)
                    {
                        [result setFlag:STKPXLexemeFlagFollowsWhitespace];
                    }
                }

                break;
            }
        }
    }
    else if (stateStack_.count > 0)
    {
        [self popSource];

        result = self.nextLexeme;
    }

    return result;
}

#pragma mark - Overrides

- (void)dealloc
{
    tokens_ = nil;
    lexemeStack_ = nil;
    stateStack_ = nil;
    _source = nil;
    _delegate = nil;
}

@end
