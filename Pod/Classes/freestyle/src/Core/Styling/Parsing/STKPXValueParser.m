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
//  STKPXValueParser.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 9/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXValueParser.h"
#import "STKPXStylesheetLexer.h"
#import "STKPXStylesheetTokenType.h"
#import "STKPXLinearGradient.h"
#import "STKPXRadialGradient.h"
#import "STKPXSolidPaint.h"
#import "STKPXPaintGroup.h"
#import "STKPXDimension.h"
#import "UIColor+STKPXColors.h"
#import "STKPXShadow.h"
#import "STKPXShadowGroup.h"
#import "STKPXStylesheetLexer.h"
#import "PixateFreestyle.h"
#import "STKPXAnimationInfo.h"
#import "STKPXValue.h"
#import "STKPXImagePaint.h"

@implementation STKPXValueParser
{
    NSArray *_lexemes;
    NSUInteger _lexemeIndex;
}

#pragma mark - Statics

static NSIndexSet *COLOR_SET;
static NSIndexSet *PAINT_SET;
static NSIndexSet *NUMBER_SET;

static NSDictionary *BLEND_MODE_MAP;
static NSDictionary *ANIMATION_DIRECTION_MAP;
static NSDictionary *ANIMATION_PLAY_STATE_MAP;
static NSDictionary *ANIMATION_FILL_MODE_MAP;
static NSDictionary *ANIMATION_TIMING_FUNCTION_MAP;

static NSString *FILE_SCHEME = @"file://";
static NSString *HTTP_SCHEME = @"http://";
static NSString *HTTPS_SCHEME = @"https://";
static NSString *DOCUMENTS_SCHEME = @"documents://";
static NSString *BUNDLE_SCHEME = @"bundle://";
static NSString *TMP_SCHEME = @"tmp://";
static NSString *DATA_SCHEME = @"data:";
static NSString *ASSET_SCHEME = @"asset://";

+ (void)initialize
{
    if (!COLOR_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:STKPXSS_RGB];
        [set addIndex:STKPXSS_RGBA];
        [set addIndex:STKPXSS_HSB];
        [set addIndex:STKPXSS_HSBA];
        [set addIndex:STKPXSS_HSL];
        [set addIndex:STKPXSS_HSLA];
        [set addIndex:STKPXSS_HEX_COLOR];
        [set addIndex:STKPXSS_IDENTIFIER];
        COLOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    // depends on COLOR_SET
    if (!PAINT_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndexes:COLOR_SET];
        [set addIndex:STKPXSS_LINEAR_GRADIENT];
        [set addIndex:STKPXSS_RADIAL_GRADIENT];
        [set addIndex:STKPXSS_URL];
        PAINT_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!NUMBER_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:STKPXSS_NUMBER];
        [set addIndex:STKPXSS_LENGTH];
        NUMBER_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!BLEND_MODE_MAP)
    {
        BLEND_MODE_MAP = @{
            @"normal" : @(kCGBlendModeNormal),
            @"multiply" : @(kCGBlendModeMultiply),
            @"screen" : @(kCGBlendModeScreen),
            @"overlay" : @(kCGBlendModeOverlay),
            @"darken" : @(kCGBlendModeDarken),
            @"lighten" : @(kCGBlendModeLighten),
            @"color-dodge" : @(kCGBlendModeColorDodge),
            @"color-burn" : @(kCGBlendModeColorBurn),
            @"soft-light" : @(kCGBlendModeSoftLight),
            @"hard-light" : @(kCGBlendModeHardLight),
            @"difference" : @(kCGBlendModeDifference),
            @"exclusion" : @(kCGBlendModeExclusion),
            @"hue" : @(kCGBlendModeHue),
            @"saturation" : @(kCGBlendModeSaturation),
            @"color": @(kCGBlendModeColor),
            @"luminosity": @(kCGBlendModeLuminosity),
            @"clear" : @(kCGBlendModeClear),
            @"copy" : @(kCGBlendModeCopy),
            @"source-in" : @(kCGBlendModeSourceIn),
            @"source-out" : @(kCGBlendModeSourceOut),
            @"source-atop" : @(kCGBlendModeSourceAtop),
            @"destination-over" : @(kCGBlendModeDestinationOver),
            @"destination-in" : @(kCGBlendModeDestinationIn),
            @"destination-out" : @(kCGBlendModeDestinationOut),
            @"destination-atop": @(kCGBlendModeDestinationAtop),
            @"xor" : @(kCGBlendModeXOR),
            @"plus-darker" : @(kCGBlendModePlusDarker),
            @"plus-lighter" : @(kCGBlendModePlusLighter)
        };
    }

    if (!ANIMATION_DIRECTION_MAP)
    {
        ANIMATION_DIRECTION_MAP = @{
            @"normal": @(STKPXAnimationDirectionNormal),
            @"reverse": @(STKPXAnimationDirectionReverse),
            @"alternate": @(STKPXAnimationDirectionAlternate),
            @"alternate-reverse": @(STKPXAnimationDirectionAlternateReverse),
        };
    }

    if (!ANIMATION_PLAY_STATE_MAP)
    {
        ANIMATION_PLAY_STATE_MAP = @{
             @"running": @(STKPXAnimationPlayStateRunning),
             @"paused": @(STKPXAnimationPlayStatePaused),
         };
    }

    if (!ANIMATION_FILL_MODE_MAP)
    {
        ANIMATION_FILL_MODE_MAP = @{
            @"none": @(STKPXAnimationFillModeNone),
            @"forwards" : @(STKPXAnimationFillModeForwards),
            @"backwards" : @(STKPXAnimationFillModeBackwards),
            @"both" : @(STKPXAnimationFillModeBoth),
        };
    }

    if (!ANIMATION_TIMING_FUNCTION_MAP)
    {
        ANIMATION_TIMING_FUNCTION_MAP = @{
            @"ease": @(STKPXAnimationTimingFunctionEase),
            @"linear": @(STKPXAnimationTimingFunctionLinear),
            @"ease-in": @(STKPXAnimationTimingFunctionEaseIn),
            @"ease-out": @(STKPXAnimationTimingFunctionEaseOut),
            @"ease-in-out": @(STKPXAnimationTimingFunctionEaseInOut),
            @"step-start": @(STKPXAnimationTimingFunctionStepStart),
            @"step-end": @(STKPXAnimationTimingFunctionStepEnd),
            // steps(<integer>[, [ start | end ] ]?)
            // cubic-bezier(<number>, <number>, <number>, <number>)
        };
    }
}

+ (NSArray *)lexemesForSource:(NSString *)source
{
    NSMutableArray *lexemes = [NSMutableArray array];

    if (source.length > 0)
    {
        static STKPXStylesheetLexer *lexer;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            lexer = [[STKPXStylesheetLexer alloc] init];
        });

        lexer.source = source;
        [lexer increaseNesting];
        STKPXStylesheetLexeme *lexeme = lexer.nextLexeme;

        while (lexeme)
        {
            [lexemes addObject:lexeme];

            lexeme = lexer.nextLexeme;
        }
    }

    return lexemes;
}

+ (NSString *)documentsFilePath
{
    static __strong NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];

        if (urls.count > 0)
        {
            NSURL *url = urls[0];

            path = url.path;
        }
        else
        {
            path = @"";
        }
    });

    return path;
}

+ (NSString *)tmpFilePath
{
    static __strong NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = NSTemporaryDirectory();

        if (path.length > 0)
        {
            path = [path substringToIndex:path.length - 1];
        }
    });

    return path;
}

#pragma mark - Initialization

- (void)setupWithLexemes:(NSArray *)lexemes
{
    [self clearErrors];
    [self setLexemes:lexemes];
    [self advance];
}

#pragma mark - Setters

- (void)setLexemes:(NSArray *)lexemes
{
    self->_lexemes = lexemes;
    self->_lexemeIndex = 0;
}

#pragma mark - Methods

- (NSArray *)parseAnimationInfos:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        [items addObject:[self parseAnimationInfo]];

        while ([self isType:STKPXSS_COMMA])
        {
            [self advance];

            [items addObject:[self parseAnimationInfo]];
        }
    }
    @catch (NSException *e)
    {
        [self errorWithMessage:e.description];
    }

    return items;
}

- (NSArray *)parseTransitionInfos:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        [items addObject:[self parseTransitionInfo]];

        while ([self isType:STKPXSS_COMMA])
        {
            [self advance];

            [items addObject:[self parseTransitionInfo]];
        }
    }
    @catch (NSException *e)
    {
        [self errorWithMessage:e.description];
    }

    return items;
}

- (STKPXAnimationInfo *)parseAnimationInfo
{
    static NSSet *KEYWORDS;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableSet *s = [[NSMutableSet alloc] init];

        [s addObjectsFromArray:ANIMATION_DIRECTION_MAP.allKeys];
        [s addObjectsFromArray:ANIMATION_FILL_MODE_MAP.allKeys];
        [s addObjectsFromArray:ANIMATION_PLAY_STATE_MAP.allKeys];
        [s addObjectsFromArray:ANIMATION_TIMING_FUNCTION_MAP.allKeys];

        KEYWORDS = [NSSet setWithSet:s];
    });

    STKPXAnimationInfo *info = [[STKPXAnimationInfo alloc] init];

    if ([self isType:STKPXSS_IDENTIFIER] && ![KEYWORDS containsObject:currentLexeme.value])
    {
        info.animationName = currentLexeme.value;
        [self advance];
    }
    if ([self isType:STKPXSS_TIME])
    {
        info.animationDuration = self.secondsValue;
    }
    if ([self isType:STKPXSS_IDENTIFIER] && (ANIMATION_TIMING_FUNCTION_MAP[currentLexeme.value] != nil))
    {
        info.animationTimingFunction = self.animationTimingFunction;
    }
    if ([self isType:STKPXSS_TIME])
    {
        info.animationDelay = self.secondsValue;
    }
    if ([self isType:STKPXSS_NUMBER])
    {
        NSNumber *number = currentLexeme.value;

        info.animationIterationCount = (int) number.floatValue;

        [self advance];
    }
    if ([self isType:STKPXSS_IDENTIFIER] && (ANIMATION_DIRECTION_MAP[currentLexeme.value] != nil))
    {
        info.animationDirection = self.animationDirection;
    }
    if ([self isType:STKPXSS_IDENTIFIER] && (ANIMATION_FILL_MODE_MAP[currentLexeme.value] != nil))
    {
        info.animationFillMode = self.animationFillMode;
    }
    if ([self isType:STKPXSS_IDENTIFIER] && (ANIMATION_PLAY_STATE_MAP[currentLexeme.value] != nil))
    {
        info.animationPlayState = self.animationPlayState;
    }

    return info;
}

- (STKPXAnimationInfo *)parseTransitionInfo
{
    STKPXAnimationInfo *info = [[STKPXAnimationInfo alloc] init];

    if ([self isType:STKPXSS_IDENTIFIER] && (ANIMATION_TIMING_FUNCTION_MAP[currentLexeme.value] == nil))
    {
        info.animationName = currentLexeme.value;
        [self advance];
    }
    if ([self isType:STKPXSS_TIME])
    {
        info.animationDuration = self.secondsValue;
    }
    if ([self isType:STKPXSS_IDENTIFIER] && (ANIMATION_TIMING_FUNCTION_MAP[currentLexeme.value] != nil))
    {
        info.animationTimingFunction = self.animationTimingFunction;
    }
    if ([self isType:STKPXSS_TIME])
    {
        info.animationDelay = self.secondsValue;
    }

    return info;
}

- (NSArray *)parseAnimationDirectionList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            [items addObject:@(self.animationDirection)];
            [self advance];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over ','

                if ([self isType:STKPXSS_IDENTIFIER])
                {
                    [items addObject:@(self.animationDirection)];
                    [self advance];
                }
                else
                {
                    [self errorWithMessage:@"Expected an animation direction after a comma in the times list"];
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return items;
}

- (NSArray *)parseAnimationFillModeList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            [items addObject:@(self.animationFillMode)];
            [self advance];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over ','

                if ([self isType:STKPXSS_IDENTIFIER])
                {
                    [items addObject:@(self.animationFillMode)];
                    [self advance];
                }
                else
                {
                    [self errorWithMessage:@"Expected an animation fill mode after a comma in the times list"];
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return items;
}

- (NSArray *)parseAnimationPlayStateList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            [items addObject:@(self.animationPlayState)];
            [self advance];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over ','

                if ([self isType:STKPXSS_IDENTIFIER])
                {
                    [items addObject:@(self.animationPlayState)];
                    [self advance];
                }
                else
                {
                    [self errorWithMessage:@"Expected an animation play state after a comma in the times list"];
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return items;
}

- (NSArray *)parseAnimationTimingFunctionList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            [items addObject:@(self.animationTimingFunction)];
            [self advance];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over ','

                if ([self isType:STKPXSS_IDENTIFIER])
                {
                    [items addObject:@(self.animationTimingFunction)];
                    [self advance];
                }
                else
                {
                    [self errorWithMessage:@"Expected an animation timing function after a comma in the times list"];
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return items;
}

- (STKPXBorderInfo *)parseBorder:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    STKPXBorderInfo *settings = [[STKPXBorderInfo alloc] init];

    @try
    {
        if ([self isInTypeSet:NUMBER_SET])
        {
            settings.width = [self readNumber];
        }
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            settings.style = [self parseBorderStyle];
        }
        if ([self isInTypeSet:PAINT_SET])
        {
            settings.paint = [self parseSinglePaint];
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return settings;
}

- (NSArray *)parseBorderRadiusList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    CGSize topLeft = CGSizeZero;
    CGSize topRight = CGSizeZero;
    CGSize bottomRight = CGSizeZero;
    CGSize bottomLeft = CGSizeZero;

    @try
    {
        STKPXOffsets *xRadii = self.parseOffsets;

        topLeft.width = topLeft.height = xRadii.top;
        topRight.width = topRight.height = xRadii.right;
        bottomRight.width = bottomRight.height = xRadii.bottom;
        bottomLeft.width = bottomLeft.height = xRadii.left;

        if ([self isType:STKPXSS_SLASH])
        {
            // advance over '/'
            [self advance];

            STKPXOffsets *yRadii = self.parseOffsets;

            topLeft.height = yRadii.top;
            topRight.height = yRadii.right;
            bottomRight.height = yRadii.bottom;
            bottomLeft.height = yRadii.left;
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return @[ [NSValue valueWithCGSize:topLeft], [NSValue valueWithCGSize:topRight], [NSValue valueWithCGSize:bottomRight], [NSValue valueWithCGSize:bottomLeft] ];
}

- (NSArray *)parseBorderStyleList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    STKPXBorderStyle top = STKPXBorderStyleNone;
    STKPXBorderStyle right = STKPXBorderStyleNone;
    STKPXBorderStyle bottom = STKPXBorderStyleNone;
    STKPXBorderStyle left = STKPXBorderStyleNone;

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            top = right = bottom = left = [self parseBorderStyle];
        }

        if ([self isType:STKPXSS_IDENTIFIER])
        {
            right = left = [self parseBorderStyle];
        }

        if ([self isType:STKPXSS_IDENTIFIER])
        {
            bottom = [self parseBorderStyle];
        }

        if ([self isType:STKPXSS_IDENTIFIER])
        {
            left = [self parseBorderStyle];
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return @[
        [[STKPXValue alloc] initWithBytes:&top type:STKPXValueType_STKPXBorderStyle],
        [[STKPXValue alloc] initWithBytes:&right type:STKPXValueType_STKPXBorderStyle],
        [[STKPXValue alloc] initWithBytes:&bottom type:STKPXValueType_STKPXBorderStyle],
        [[STKPXValue alloc] initWithBytes:&left type:STKPXValueType_STKPXBorderStyle]
    ];
}

- (STKPXBorderStyle)parseBorderStyle:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    return [self parseBorderStyle];
}

- (STKPXBorderStyle)parseBorderStyle
{
    static NSDictionary *MAP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MAP = @{
            @"none": @(STKPXBorderStyleNone),
            @"hidden": @(STKPXBorderStyleHidden),
            @"dotted": @(STKPXBorderStyleDotted),
            @"dashed": @(STKPXBorderStyleDashed),
            @"solid": @(STKPXBorderStyleSolid),
            @"double": @(STKPXBorderStyleDouble),
            @"groove": @(STKPXBorderStyleGroove),
            @"ridge": @(STKPXBorderStyleRidge),
            @"inset": @(STKPXBorderStyleInset),
            @"outset": @(STKPXBorderStyleOutset),
        };
    });

    STKPXBorderStyle result = STKPXBorderStyleNone;

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            NSString *text = currentLexeme.value;
            NSNumber *value = [MAP valueForKey:text.lowercaseString];

            if (value)
            {
                result = (STKPXBorderStyle) value.intValue;
            }

            [self advance];
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (UIColor *)parseColor:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    UIColor *result = nil;

    @try
    {
        result = self.color;
    }
    @catch(NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (CGFloat)parseFloat:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    CGFloat result = 0.0f;

    @try
    {
        result = self.floatValue;
    }
    @catch(NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (NSArray *)parseFloatList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        if ([self isType:STKPXSS_NUMBER])
        {
            [items addObject:currentLexeme.value];
            [self advance];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over ','

                if ([self isType:STKPXSS_NUMBER])
                {
                    [items addObject:currentLexeme.value];
                    [self advance];
                }
                else
                {
                    [self errorWithMessage:@"Expected an number after a comma in the number list"];
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return items;
}

- (NSArray *)parseNameList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            [items addObject:currentLexeme.value];
            [self advance];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over ','
                [self advance];

                if ([self isType:STKPXSS_IDENTIFIER])
                {
                    [items addObject:currentLexeme.value];
                    [self advance];
                }
                else
                {
                    [self errorWithMessage:@"Expected an identifier after a comma in the name list"];
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return items;
}

- (NSArray *)parsePaints:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    id<STKPXPaint> topPaint = nil;
    id<STKPXPaint> rightPaint = nil;
    id<STKPXPaint> bottomPaint = nil;
    id<STKPXPaint> leftPaint = nil;

    @try
    {
        // NOTE: There can be zero or more paints in the token stream. If the very first item is not a paint, we go
        // ahead and default all colors to black. The following if-blocks will fail, so doing it here is similar to
        // setting a default value for these items.
        if ([self isInTypeSet:PAINT_SET])
        {
            topPaint = rightPaint = bottomPaint = leftPaint = [self parseSinglePaint];
        }
        else
        {
            topPaint = rightPaint = bottomPaint = leftPaint = [STKPXSolidPaint paintWithColor:[UIColor blackColor]];
        }

        if ([self isInTypeSet:PAINT_SET])
        {
            rightPaint = leftPaint = [self parseSinglePaint];
        }

        if ([self isInTypeSet:PAINT_SET])
        {
            bottomPaint = [self parseSinglePaint];
        }

        if ([self isInTypeSet:PAINT_SET])
        {
            leftPaint = [self parseSinglePaint];
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return @ [ topPaint, rightPaint, bottomPaint, leftPaint ];
}

- (id<STKPXPaint>)parsePaint:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    id<STKPXPaint> result = nil;

    @try
    {
        result = [self parseSinglePaint];

        if ([self isType:STKPXSS_COMMA])
        {
            STKPXPaintGroup *group = [[STKPXPaintGroup alloc] init];

            [group addPaint:result];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over comma, ','
                [self advance];

                [group addPaint:[self parseSinglePaint]];
            }

            result = group;
        }
    }
    @catch(NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (NSArray *)parseSecondsList:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    @try
    {
        if ([self isType:STKPXSS_TIME])
        {
            [items addObject:@(self.secondsValue)];
            [self advance];

            while ([self isType:STKPXSS_COMMA])
            {
                // advance over ','

                if ([self isType:STKPXSS_TIME])
                {
                    [items addObject:@(self.secondsValue)];
                    [self advance];
                }
                else
                {
                    [self errorWithMessage:@"Expected an time after a comma in the times list"];
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return items;
}

- (id<STKPXShadowPaint>)parseShadow:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    id<STKPXShadowPaint> result = nil;

    @try
    {
        result = [self parseShadow];

        if ([self isType:STKPXSS_COMMA])
        {
            STKPXShadowGroup *group = [[STKPXShadowGroup alloc] init];

            [group addShadowPaint:result];

            while ([self isType:STKPXSS_COMMA])
            {
                // skip over ','
                [self advance];

                [group addShadowPaint:[self parseShadow]];
            }

            result = group;
        }
    }
    @catch(NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (STKPXShadow *)parseShadow
{
    STKPXShadow *result = [[STKPXShadow alloc] init];

    if ([self isIdentifierWithName:@"inset"])
    {
        result.inset = YES;
        [self advance];
    }

    // grab required x-offset
    [self assertTypeInSet:NUMBER_SET];
    result.horizontalOffset = self.floatValue;

    // grab required y-offset
    [self assertTypeInSet:NUMBER_SET];
    result.verticalOffset = self.floatValue;

    // next two lengths are optional
    if ([self isInTypeSet:NUMBER_SET])
    {
        result.blurDistance = self.floatValue;

        if ([self isInTypeSet:NUMBER_SET])
        {
            result.spreadDistance = self.floatValue;
        }
    }

    // color is optional
    result.color = ([self isInTypeSet:COLOR_SET]) ? self.color : [UIColor blackColor];

    return result;
}

- (CGSize)parseSize:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    CGFloat width = 0.0f;
    CGFloat height = 0.0f;

    @try
    {
        // one number
        if ([self isInTypeSet:NUMBER_SET])
        {
            width = height = [self readNumber];
        }

        // two numbers
        if ([self isInTypeSet:NUMBER_SET])
        {
            height = [self readNumber];
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return CGSizeMake(width, height);
}

- (NSURL *)parseURL:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    return [self parseURL];
}

- (NSURL *)parseURL
{
    NSURL *result = nil;

    @try
    {
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            // NOTE: technically we should look for "none", but if we don't recognize the identifier, we'll want to
            // treat it as none anyway
            [self advance];
        }
        else
        {
            [self assertType:STKPXSS_URL];
            NSString *unescapedPath = currentLexeme.value;
            NSString *path = [unescapedPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self advance];

            __block NSMutableArray *fullPaths = [[NSMutableArray alloc] init];

            void (^addWith2xVersions)(NSString *) = ^(NSString *path) {
                if (path)
                {
                    NSString *pathMinusExtension = path.stringByDeletingPathExtension;

                    if (![pathMinusExtension hasSuffix:@"@2x"])
                    {
                        NSString *extension = path.pathExtension.lowercaseString;
                        NSString *path2x = [NSString stringWithFormat:@"%@@2x.%@", pathMinusExtension, extension];

                        if ([UIScreen mainScreen].scale == 2.0f)
                        {
                            [fullPaths addObject:path2x];
                            [fullPaths addObject:path];
                        }
                        else
                        {
                            [fullPaths addObject:path];
                            [fullPaths addObject:path2x];
                        }
                    }
                    else
                    {
                        [fullPaths addObject:path];
                    }
                }
            };

            if ([path hasPrefix:FILE_SCHEME])
            {
                addWith2xVersions([path substringFromIndex:FILE_SCHEME.length]);
            }
            else if ([path hasPrefix:HTTP_SCHEME] || [path hasPrefix:HTTPS_SCHEME])
            {
                result = [NSURL URLWithString:unescapedPath];
            }
            else if ([path hasPrefix:DOCUMENTS_SCHEME])
            {
                addWith2xVersions([NSString stringWithFormat:@"%@/%@", [STKPXValueParser documentsFilePath], [path substringFromIndex:DOCUMENTS_SCHEME.length]]);
            }
            else if ([path hasPrefix:BUNDLE_SCHEME])
            {
                path = [path substringFromIndex:BUNDLE_SCHEME.length];
                NSString *pathMinusExtension = path.stringByDeletingPathExtension;
                NSString *extension = path.pathExtension.lowercaseString;

                addWith2xVersions([[NSBundle mainBundle] pathForResource:pathMinusExtension ofType:extension]);
            }
            else if ([path hasPrefix:ASSET_SCHEME])
            {
                path = [path substringFromIndex:ASSET_SCHEME.length];
                NSString *pathMinusExtension = path.stringByDeletingPathExtension;
                
                result = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ASSET_SCHEME, pathMinusExtension]];
            }
            else if ([path hasPrefix:TMP_SCHEME])
            {
                addWith2xVersions([NSString stringWithFormat:@"%@/%@", [STKPXValueParser tmpFilePath], [path substringFromIndex:TMP_SCHEME.length]]);
            }
            else if ([path hasPrefix:DATA_SCHEME])
            {
                NSArray *parts = [path componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *normalizedString = [parts componentsJoinedByString:@""];

                result = [[NSURL alloc] initWithString:normalizedString];
            }
            else
            {
                addWith2xVersions([NSString stringWithFormat:@"%@/%@", [STKPXValueParser documentsFilePath], path]);

                NSString *pathMinusExtension = path.stringByDeletingPathExtension;
                NSString *extension = path.pathExtension.lowercaseString;

                addWith2xVersions([[NSBundle mainBundle] pathForResource:pathMinusExtension ofType:extension]);
            }

            for (NSString *fullPath in fullPaths)
            {
                if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
                {
                    result = [NSURL fileURLWithPath:fullPath];
                    break;
                }
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (UIEdgeInsets)parseInsets:(NSArray *)lexemes
{
    STKPXOffsets *margin = [self parseOffsets:lexemes];

    return UIEdgeInsetsMake(margin.top, margin.left, margin.bottom, margin.right);
}

//- (STKPXCornerRadius *)parseCornerRadius:(NSArray *)lexemes
//{
//    STKPXOffsets *margin = [self parseOffsets:lexemes];
//
//    return [[STKPXCornerRadius alloc] initWithTopLeft:margin.top topRight:margin.right bottomRight:margin.bottom bottomLeft:margin.left];
//}

- (STKPXOffsets *)parseOffsets:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    return self.parseOffsets;
}

- (STKPXOffsets *)parseOffsets
{
    CGFloat top = 0.0f;
    CGFloat left = 0.0f;
    CGFloat bottom = 0.0f;
    CGFloat right = 0.0f;

    @try
    {
        // one number
        if ([self isInTypeSet:NUMBER_SET])
        {
            top = right = bottom = left = [self readNumber];
        }

        // two numbers
        if ([self isInTypeSet:NUMBER_SET])
        {
            right = left = [self readNumber];
        }

        // three numbers
        if ([self isInTypeSet:NUMBER_SET])
        {
            bottom = [self readNumber];
        }

        // four numbers
        if ([self isInTypeSet:NUMBER_SET])
        {
            left = [self readNumber];
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return [[STKPXOffsets alloc] initWithTop:top right:right bottom:bottom left:left];
}

- (CGFloat)parseSeconds:(NSArray *)lexemes
{
    [self setupWithLexemes:lexemes];

    CGFloat seconds = 0.0f;

    @try
    {
        seconds = self.secondsValue;
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return seconds;
}

// level 1

- (id<STKPXPaint>)parseSinglePaint
{
    id<STKPXPaint> result = nil;

    if ([self isInTypeSet:PAINT_SET])
    {
        if ([self isType:STKPXSS_LINEAR_GRADIENT])
        {
            result = self.linearGradient;
        }
        else if ([self isType:STKPXSS_RADIAL_GRADIENT])
        {
            result = self.radialGradient;
        }
        else if ([self isType:STKPXSS_URL])
        {
            result = [[STKPXImagePaint alloc] initWithURL:[self parseURL]];
        }
        else if ([self isInTypeSet:COLOR_SET])
        {
            result = [STKPXSolidPaint paintWithColor:self.color];
        }
        else
        {
            [self errorWithMessage:@"Unsupported paint token type"];
        }

        if ([self isType:STKPXSS_IDENTIFIER])
        {
            NSString *blendingMode = currentLexeme.value;
            NSNumber *blendModeValue = BLEND_MODE_MAP[blendingMode];

            result.blendMode = (blendModeValue) ? blendModeValue.intValue : kCGBlendModeNormal;

            [self advance];
        }
    }
    else
    {
        [self errorWithMessage:@"Unrecognized paint token type"];
    }

    return result;
}

- (STKPXLinearGradient *)linearGradient
{
    STKPXLinearGradient *result = [[STKPXLinearGradient alloc] init];

    [self assertTypeAndAdvance:STKPXSS_LINEAR_GRADIENT];

    if ([self isType:STKPXSS_ANGLE])
    {
        // NOTE: getAngleValue auto-advances for us
        result.cssAngle = self.angleValue;

        // skip optional comma
        [self advanceIfIsType:STKPXSS_COMMA];
    }
    else if ([self isIdentifierWithName:@"to"])
    {
        // advance over 'to'
        [self advance];

        // look for direction indicator
        if ([self isType:STKPXSS_IDENTIFIER])
        {
            NSString *text = currentLexeme.value;

            if ([@"left" isEqualToString:text])
            {
                [self advance];

                if ([self isIdentifierWithName:@"top"])
                {
                    // advance over 'top'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToTopLeft;
                }
                else if ([self isIdentifierWithName:@"bottom"])
                {
                    // advance over 'bottom'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToBottomLeft;
                }
                else
                {
                    result.gradientDirection = STKPXLinearGradientDirectionToLeft;
                }
            }
            else if ([@"right" isEqualToString:text])
            {
                [self advance];

                if ([self isIdentifierWithName:@"top"])
                {
                    // advance over 'top'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToTopRight;
                }
                else if ([self isIdentifierWithName:@"bottom"])
                {
                    // advance over 'bottom'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToBottomRight;
                }
                else
                {
                    result.gradientDirection = STKPXLinearGradientDirectionToRight;
                }
            }
            else if ([@"top" isEqualToString:text])
            {
                [self advance];

                if ([self isIdentifierWithName:@"left"])
                {
                    // advance over 'left'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToTopLeft;
                }
                else if ([self isIdentifierWithName:@"right"])
                {
                    // advance over 'right'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToTopRight;
                }
                else
                {
                    result.gradientDirection = STKPXLinearGradientDirectionToTop;
                }
            }
            else if ([@"bottom" isEqualToString:text])
            {
                [self advance];

                if ([self isIdentifierWithName:@"left"])
                {
                    // advance over 'left'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToBottomLeft;
                }
                else if ([self isIdentifierWithName:@"right"])
                {
                    // advance over 'right'
                    [self advance];

                    result.gradientDirection = STKPXLinearGradientDirectionToBottomRight;
                }
                else
                {
                    result.gradientDirection = STKPXLinearGradientDirectionToBottom;
                }
            }
            else
            {
                [self errorWithMessage:@"Expected 'top', 'right', 'bottom', or 'left' keyword after 'to' when defining a linear gradient angle"];
            }

            // skip optional comma
            [self advanceIfIsType:STKPXSS_COMMA];
        }
        else
        {
            [self errorWithMessage:@"Expected 'top', 'right', 'bottom', or 'left' keyword after 'to' when defining a linear gradient angle"];
        }
    }

    // collect colors
    do {
        UIColor *color = self.color;

        if ([self isType:STKPXSS_PERCENTAGE])
        {
            // NOTE: getFloatValue auto-advances for us
            STKPXDimension *percent = currentLexeme.value;

            CGFloat offset = percent.number / 100.0f;

            [self advance];

            [result addColor:color withOffset:offset];
        }
        else
        {
            [result addColor:color];
        }

        // skip optional comma
        [self advanceIfIsType:STKPXSS_COMMA];

    } while ([self isInTypeSet:COLOR_SET]);

    // advance over ')'
    [self assertTypeAndAdvance:STKPXSS_RPAREN];

    return result;
}

- (STKPXRadialGradient *)radialGradient
{
    STKPXRadialGradient *result = [[STKPXRadialGradient alloc] init];

    [self assertTypeAndAdvance:STKPXSS_RADIAL_GRADIENT];

    // collect colors
    do {
        UIColor *color = self.color;

        if ([self isType:STKPXSS_PERCENTAGE])
        {
            // NOTE: getFloatValue auto-advances for us
            CGFloat offset = self.percentageValue;

            [result addColor:color withOffset:offset];
        }
        else
        {
            [result addColor:color];
        }

        // skip optional comma
        [self advanceIfIsType:STKPXSS_COMMA];

    } while ([self isInTypeSet:COLOR_SET]);

    // advance over ')'
    [self assertTypeAndAdvance:STKPXSS_RPAREN];

    return result;
}

- (UIColor *)color
{
    UIColor *result = nil;

    // read a value from [0,255] or a percentage and return in range [0,1]
    CGFloat (^readByteOrPercent)(CGFloat) = ^CGFloat(CGFloat divisor) {
        CGFloat result = 0.0f;

        if ([self isType:STKPXSS_NUMBER])
        {
            NSNumber *number = (NSNumber *)currentLexeme.value;

            result = number.floatValue / divisor;

            [self advance];
        }
        else if ([self isType:STKPXSS_PERCENTAGE])
        {
            CGFloat percent = ((STKPXDimension *)currentLexeme.value).number;

            result = percent / 100.0f;

            [self advance];
        }

        [self advanceIfIsType:STKPXSS_COMMA];

        return result;
    };

    // read a value from [0,360] or an angle and return in range [0,1]
    CGFloat (^readAngle)() = ^CGFloat() {
        CGFloat result = 0.0f;

        if ([self isType:STKPXSS_NUMBER])
        {
            NSNumber *number = (NSNumber *)currentLexeme.value;

            result = number.floatValue / 360.0f;

            [self advance];
        }
        else if ([self isType:STKPXSS_ANGLE])
        {
            STKPXDimension *degrees = ((STKPXDimension *)currentLexeme.value).degrees;

            result = degrees.number / 360.0f;

            [self advance];
        }

        [self advanceIfIsType:STKPXSS_COMMA];

        return result;
    };

    switch (currentLexeme.type)
    {
        case STKPXSS_RGB:
            [self advance];
            result = [UIColor colorWithRed:readByteOrPercent(255.0f)
                                     green:readByteOrPercent(255.0f)
                                      blue:readByteOrPercent(255.0f)
                                     alpha:1.0f];
            [self assertTypeAndAdvance:STKPXSS_RPAREN];
            break;

        case STKPXSS_RGBA:
        {
            CGFloat r, g, b, a;

            [self advance];

            if ([self isType:STKPXSS_HEX_COLOR])
            {
                UIColor *c = [UIColor colorWithHexString:currentLexeme.value];

                [c getRed:&r green:&g blue:&b alpha:&a];
                [self advance];
                [self advanceIfIsType:STKPXSS_COMMA];
            }
            else if ([self isType:STKPXSS_IDENTIFIER])
            {
                UIColor *c = [UIColor colorFromName:currentLexeme.value];

                [c getRed:&r green:&g blue:&b alpha:&a];
                [self advance];
                [self advanceIfIsType:STKPXSS_COMMA];
            }
            else
            {
                r = readByteOrPercent(255.0f);
                g = readByteOrPercent(255.0f);
                b = readByteOrPercent(255.0f);
            }

            a = readByteOrPercent(1.0f);
            result = [UIColor colorWithRed:r green:g blue:b alpha:a];

            [self assertTypeAndAdvance:STKPXSS_RPAREN];
            break;
        }

        case STKPXSS_HSL:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                 lightness:readByteOrPercent(255.0f)
                                     alpha:1.0f];
            [self assertTypeAndAdvance:STKPXSS_RPAREN];
            break;

        case STKPXSS_HSLA:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                 lightness:readByteOrPercent(255.0f)
                                     alpha:readByteOrPercent(1.0f)];
            [self assertTypeAndAdvance:STKPXSS_RPAREN];
            break;

        case STKPXSS_HSB:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                brightness:readByteOrPercent(255.0f)
                                     alpha:1.0f];
            [self assertTypeAndAdvance:STKPXSS_RPAREN];
            break;

        case STKPXSS_HSBA:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                brightness:readByteOrPercent(255.0f)
                                     alpha:readByteOrPercent(1.0f)];
            [self assertTypeAndAdvance:STKPXSS_RPAREN];
            break;

        case STKPXSS_HEX_COLOR:
            result = [UIColor colorWithHexString:currentLexeme.value];
            [self advance];
            break;

        case STKPXSS_IDENTIFIER:
            result = [UIColor colorFromName:currentLexeme.value];
            [self advance];
            break;

        default:
            [self errorWithMessage:@"Expected RGB, RGBA, HSB, HSBA, HSL, HSLA, COLOR (hex color), or IDENTIFIER (named color)"];
    }

    return result;
}

#pragma mark - Overrides

- (STKPXStylesheetLexeme *)advance
{
    return currentLexeme = (_lexemeIndex < _lexemes.count) ? _lexemes[_lexemeIndex++] : nil;
}

- (NSString *)lexemeNameFromType:(int)type
{
    STKPXStylesheetLexeme *lexeme = [[STKPXStylesheetLexeme alloc] initWithType:type text:nil];

    return lexeme.name;
}

#pragma mark - Helper Methods

- (CGFloat)angleValue
{
    CGFloat result = 0.0;

    [self assertType:STKPXSS_ANGLE];

    id value = currentLexeme.value;

    if ([value isKindOfClass:[STKPXDimension class]])
    {
        STKPXDimension *dimension = value;

        result = dimension.number;
    }
    else
    {
        [self errorWithMessage:@"ANGLE lexeme did not have STKPXDimension value"];
    }

    [self advance];

    return result;
}

- (STKPXAnimationDirection)animationDirection
{
    STKPXAnimationDirection result = STKPXAnimationDirectionUndefined;

    if ([self isType:STKPXSS_IDENTIFIER])
    {
        NSString *text = currentLexeme.value;
        NSNumber *value = ANIMATION_DIRECTION_MAP[text.lowercaseString];

        if (value)
        {
            result = (STKPXAnimationDirection) value.intValue;
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation direction"];
    }

    [self advance];

    return result;
}

- (STKPXAnimationPlayState)animationPlayState
{
    STKPXAnimationPlayState result = STKPXAnimationPlayStateUndefined;

    if ([self isType:STKPXSS_IDENTIFIER])
    {
        NSString *text = currentLexeme.value;
        NSNumber *value = ANIMATION_PLAY_STATE_MAP[text.lowercaseString];

        if (value)
        {
            result = (STKPXAnimationPlayState) value.intValue;
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation play state"];
    }

    [self advance];

    return result;
}

- (STKPXAnimationFillMode)animationFillMode
{
    STKPXAnimationFillMode result = STKPXAnimationFillModeUndefined;

    if ([self isType:STKPXSS_IDENTIFIER])
    {
        NSString *text = currentLexeme.value;
        NSNumber *value = ANIMATION_FILL_MODE_MAP[text.lowercaseString];

        if (value)
        {
            result = (STKPXAnimationFillMode) value.intValue;
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation fill mode"];
    }

    [self advance];

    return result;
}

- (STKPXAnimationTimingFunction)animationTimingFunction
{
    STKPXAnimationTimingFunction result = STKPXAnimationTimingFunctionUndefined;

    if ([self isType:STKPXSS_IDENTIFIER])
    {
        NSString *text = currentLexeme.value;
        NSNumber *value = ANIMATION_TIMING_FUNCTION_MAP[text.lowercaseString];

        if (value)
        {
            result = (STKPXAnimationTimingFunction) value.intValue;
        }
    }
    else
    {
        [self errorWithMessage:@"Expected identifier for animation timing function"];
    }

    [self advance];

    return result;
}

- (CGFloat)floatValue
{
    // TODO: make more robust by testing token types
    id value = currentLexeme.value;
    CGFloat result = 0.0;

    if ([value isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = (NSNumber *)value;

        result = number.floatValue;
    }
    else if ([value isKindOfClass:[STKPXDimension class]])
    {
        STKPXDimension *dimension = (STKPXDimension *)value;
        STKPXDimension *points = dimension.points;

        result = points.number;
    }

    [self advance];

    return result;
}

- (CGFloat)percentageValue
{
    CGFloat result = 0.0;

    [self assertType:STKPXSS_PERCENTAGE];

    id value = currentLexeme.value;

    if ([value isKindOfClass:[STKPXDimension class]])
    {
        STKPXDimension *dimension = value;

        result = dimension.number / 100.0;
    }
    else
    {
        [self errorWithMessage:@"PERCENTAGE lexeme did not have STKPXDimension value"];
    }

    [self advance];

    return result;
}

- (CGFloat)secondsValue
{
    CGFloat result = 0.0;

    [self assertType:STKPXSS_TIME];

    id value = currentLexeme.value;

    if ([value isKindOfClass:[STKPXDimension class]])
    {
        STKPXDimension *dimension = value;

        switch (dimension.type)
        {
            case kDimensionTypeMilliseconds:
                result = dimension.number / 1000.0f;
                break;

            case kDimensionTypeSeconds:
                result = dimension.number;
                break;

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized time unit: %@", dimension];

                [self errorWithMessage:message];
                break;
            }
        }
    }
    else
    {
        [self errorWithMessage:@"TIME lexeme did not have STKPXDimension value"];
    }

    [self advance];

    return result;
}

- (BOOL)isIdentifierWithName:(NSString *)name
{
    return [self isType:STKPXSS_IDENTIFIER] && [name isEqualToString:currentLexeme.value];
}

- (CGFloat)readNumber
{
    CGFloat result = 0.0f;

    if ([self isType:STKPXSS_NUMBER])
    {
        NSNumber *number = (NSNumber *)currentLexeme.value;

        result = number.floatValue;

        [self advance];
    }
    else if ([self isType:STKPXSS_LENGTH])
    {
        STKPXDimension *length = (STKPXDimension *)currentLexeme.value;

        result = length.points.number;

        [self advance];
    }

    [self advanceIfIsType:STKPXSS_COMMA];

    return result;
};

- (void)addError:(NSString *)error
{
    NSString *offset = (currentLexeme.type != STKPXSS_EOF) ? [NSString stringWithFormat:@"%lu", (unsigned long) currentLexeme.range.location] : @"EOF";

    [self addError:error filename:_filename offset:offset];
}

@end
