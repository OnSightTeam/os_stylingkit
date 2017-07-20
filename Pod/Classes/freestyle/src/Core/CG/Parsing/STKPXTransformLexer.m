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
//  STKPXTransformLexer.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXTransformLexer.h"
#import "STKPXTransformTokenType.h"
#import "STKPXPatternMatcher.h"
#import "STKPXNumberMatcher.h"
#import "STKPXWordMatcher.h"
#import "STKPXCharacterMatcher.h"

@implementation STKPXTransformLexer
{
    NSArray *tokens;
    NSUInteger offset;
}

@synthesize source;

#pragma mark - Initializers

- (instancetype)init
{
    if (self = [super init])
    {
        // create tokens
        NSMutableArray *tokenList = [NSMutableArray array];

        // whitespace
        [tokenList addObject: [[STKPXPatternMatcher alloc] initWithType:STKPXTransformToken_WHITESPACE
                                                     withPatternString:@"^[ \\t\\r\\n]+"]];

        // dimensions
        NSDictionary *unitMap = @{
                                  @"em": @(STKPXTransformToken_EMS),
                                  @"ex": @(STKPXTransformToken_EXS),
                                  @"STKPX": @(STKPXTransformToken_LENGTH),
                                  @"dpx": @(STKPXTransformToken_LENGTH),
                                  @"cm": @(STKPXTransformToken_LENGTH),
                                  @"mm": @(STKPXTransformToken_LENGTH),
                                  @"in": @(STKPXTransformToken_LENGTH),
                                  @"pt": @(STKPXTransformToken_LENGTH),
                                  @"pc": @(STKPXTransformToken_LENGTH),
                                  @"deg": @(STKPXTransformToken_ANGLE),
                                  @"rad": @(STKPXTransformToken_ANGLE),
                                  @"grad": @(STKPXTransformToken_ANGLE),
                                  @"ms": @(STKPXTransformToken_TIME),
                                  @"s": @(STKPXTransformToken_TIME),
                                  @"Hz": @(STKPXTransformToken_FREQUENCY),
                                  @"kHz": @(STKPXTransformToken_FREQUENCY),
                                  @"%": @(STKPXTransformToken_PERCENTAGE),
                                  @"[-a-zA-Z_][-a-zA-Z0-9_]*": @(STKPXTransformToken_DIMENSION)
                                  };
        [tokenList addObject:[[STKPXNumberMatcher alloc] initWithType:STKPXTransformToken_NUMBER withDictionary:unitMap withUnknownType:STKPXTransformToken_DIMENSION]];

        // keywords
        NSDictionary *keywordMap = @{@"translate": @(STKPXTransformToken_TRANSLATE),
                                    @"translateX": @(STKPXTransformToken_TRANSLATEX),
                                    @"translateY": @(STKPXTransformToken_TRANSLATEY),
                                    @"scale": @(STKPXTransformToken_SCALE),
                                    @"scaleX": @(STKPXTransformToken_SCALEX),
                                    @"scaleY": @(STKPXTransformToken_SCALEY),
                                    @"skew": @(STKPXTransformToken_SKEW),
                                    @"skewX": @(STKPXTransformToken_SKEWX),
                                    @"skewY": @(STKPXTransformToken_SKEWY),
                                    @"rotate": @(STKPXTransformToken_ROTATE),
                                    @"matrix": @(STKPXTransformToken_MATRIX)};
        [tokenList addObject:[[STKPXWordMatcher alloc] initWithDictionary:keywordMap]];

        // single-character operators
        NSString *operators = @"(),";
        NSArray *operatorTypes = @[@(STKPXTransformToken_LPAREN),
                                  @(STKPXTransformToken_RPAREN),
                                  @(STKPXTransformToken_COMMA)];
        [tokenList addObject:[[STKPXCharacterMatcher alloc] initWithCharactersInString:operators withTypes:operatorTypes]];

        self->tokens = tokenList;

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
    self->source = aSource;
    self->offset = 0;
}

#pragma mark - Methods

- (STKPXStylesheetLexeme *)nextLexeme
{
    STKPXStylesheetLexeme *result = nil;

    if (source)
    {
        NSUInteger length = source.length;

        while (offset < length)
        {
            NSRange range = NSMakeRange(offset, length - offset);
            STKPXStylesheetLexeme *candidate = nil;

            for (id<STKPXLexemeCreator> creator in tokens)
            {
                STKPXStylesheetLexeme *lexeme = [creator createLexemeWithString:source withRange:range];

                if (lexeme)
                {
                    NSRange lexemeRange = lexeme.range;

                    offset = lexemeRange.location + lexemeRange.length;
                    candidate = lexeme;
                    break;
                }
            }

            // skip whitespace
            if (!candidate || candidate.type != STKPXTransformToken_WHITESPACE)
            {
                result = candidate;
                break;
            }
        }
    }

    return result;
}

@end
