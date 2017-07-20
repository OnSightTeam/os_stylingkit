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
//  STKPXTransformParser.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXTransformParser.h"
#import "STKPXTransformLexer.h"
#import "STKPXTransformTokenType.h"
#import "STKPXMath.h"
#import "STKPXDimension.h"

@implementation STKPXTransformParser
{
    STKPXTransformLexer *lexer;
}

#pragma mark - Statics

static NSIndexSet *TRANSFORM_KEYWORD_SET;
static NSIndexSet *ANGLE_SET;
static NSIndexSet *LENGTH_SET;
static NSIndexSet *PERCENTAGE_SET;

+ (void)initialize
{
    if (!TRANSFORM_KEYWORD_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:STKPXTransformToken_TRANSLATE];
        [set addIndex:STKPXTransformToken_TRANSLATEX];
        [set addIndex:STKPXTransformToken_TRANSLATEY];
        [set addIndex:STKPXTransformToken_SCALE];
        [set addIndex:STKPXTransformToken_SCALEX];
        [set addIndex:STKPXTransformToken_SCALEY];
        [set addIndex:STKPXTransformToken_SKEW];
        [set addIndex:STKPXTransformToken_SKEWX];
        [set addIndex:STKPXTransformToken_SKEWY];
        [set addIndex:STKPXTransformToken_ROTATE];
        [set addIndex:STKPXTransformToken_MATRIX];
        TRANSFORM_KEYWORD_SET = set;
    }
    if (!ANGLE_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:STKPXTransformToken_NUMBER];
        [set addIndex:STKPXTransformToken_ANGLE];
        ANGLE_SET = set;
    }
    if (!LENGTH_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:STKPXTransformToken_NUMBER];
        [set addIndex:STKPXTransformToken_LENGTH];
        LENGTH_SET = set;
    }
    if (!PERCENTAGE_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:STKPXTransformToken_NUMBER];
        [set addIndex:STKPXTransformToken_PERCENTAGE];
        PERCENTAGE_SET = set;
    }
}

#pragma mark - Initializers

- (instancetype)init
{
    if (self = [super init])
    {
        self->lexer = [[STKPXTransformLexer alloc] init];
    }

    return self;
}

- (CGAffineTransform)parse:(NSString *)source
{
    CGAffineTransform result = CGAffineTransformIdentity;

    // clear errors
    [self clearErrors];

    // setup lexer and prime lexer stream
    lexer.source = source;
    [self advance];

    // TODO: move try/catch inside while loop after adding some error recovery
    @try
    {
        while (currentLexeme)
        {
            CGAffineTransform transform = [self parseTransform];

            result = CGAffineTransformConcat(transform, result);
        }
    }
    @catch(NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (CGAffineTransform) parseTransform
{
    CGAffineTransform result;

    // advance over keyword
    [self assertTypeInSet:TRANSFORM_KEYWORD_SET];
    STKPXStylesheetLexeme *transformType = currentLexeme;
    [self advance];

    // advance over '('
    [self assertTypeAndAdvance:STKPXTransformToken_LPAREN];

    switch (transformType.type)
    {
        case STKPXTransformToken_TRANSLATE:
            result = [self parseTranslate];
            break;

        case STKPXTransformToken_TRANSLATEX:
            result = [self parseTranslateX];
            break;

        case STKPXTransformToken_TRANSLATEY:
            result = [self parseTranslateY];
            break;

        case STKPXTransformToken_SCALE:
            result = [self parseScale];
            break;

        case STKPXTransformToken_SCALEX:
            result = [self parseScaleX];
            break;

        case STKPXTransformToken_SCALEY:
            result = [self parseScaleY];
            break;

        case STKPXTransformToken_SKEW:
            result = [self parseSkew];
            break;

        case STKPXTransformToken_SKEWX:
            result = [self parseSkewX];
            break;

        case STKPXTransformToken_SKEWY:
            result = [self parseSkewY];
            break;

        case STKPXTransformToken_ROTATE:
            result = [self parseRotate];
            break;

        case STKPXTransformToken_MATRIX:
            result = [self parseMatrix];
            break;

        default:
            result = CGAffineTransformIdentity;
            [self errorWithMessage:@"Unrecognized transform type"];
            break;

    }

    // advance over ')'
    [self advanceIfIsType:STKPXTransformToken_RPAREN];

    return result;
}

- (CGAffineTransform)parseMatrix
{
    CGFloat a = self.floatValue;
    CGFloat b = self.floatValue;
    CGFloat c = self.floatValue;
    CGFloat d = self.floatValue;
    CGFloat e = self.floatValue;
    CGFloat f = self.floatValue;

    return CGAffineTransformMake(a, b, c, d, e, f);
}

- (CGAffineTransform)parseRotate
{
    CGFloat angle = self.angleValue;

    if ([self isInTypeSet:LENGTH_SET])
    {
        CGFloat x = self.lengthValue;
        CGFloat y = self.lengthValue;

        CGAffineTransform result = CGAffineTransformMakeTranslation(x, y);
        result = CGAffineTransformRotate(result, angle);
        return CGAffineTransformTranslate(result, -x, -y);
    }
    else
    {
        return CGAffineTransformMakeRotation(angle);
    }
}

- (CGAffineTransform)parseScale
{
    CGFloat sx = self.floatValue;
    CGFloat sy = ([self isType:STKPXTransformToken_NUMBER]) ? self.floatValue : sx;

    return CGAffineTransformMakeScale(sx, sy);
}

- (CGAffineTransform)parseScaleX
{
    CGFloat sx = self.floatValue;

    return CGAffineTransformMakeScale(sx, 1.0f);
}

- (CGAffineTransform)parseScaleY
{
    CGFloat sy = self.floatValue;

    return CGAffineTransformMakeScale(1.0f, sy);
}

- (CGAffineTransform)parseSkew
{
    CGFloat sx = TAN(self.angleValue);
    CGFloat sy = ([self isInTypeSet:ANGLE_SET]) ? TAN(self.angleValue) : 0.0f;

    return CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f);
}

- (CGAffineTransform)parseSkewX
{
    CGFloat sx = TAN(self.angleValue);

    return CGAffineTransformMake(1.0f, 0.0f, sx, 1.0f, 0.0f, 0.0f);
}

- (CGAffineTransform)parseSkewY
{
    CGFloat sy = TAN(self.angleValue);

    return CGAffineTransformMake(1.0f, sy, 0.0f, 1.0f, 0.0f, 0.0f);
}

- (CGAffineTransform)parseTranslate
{
    CGFloat tx = self.lengthValue;
    CGFloat ty = ([self isInTypeSet:LENGTH_SET]) ? self.lengthValue : 0.0f;

    return CGAffineTransformMakeTranslation(tx, ty);
}

- (CGAffineTransform)parseTranslateX
{
    CGFloat tx = self.lengthValue;

    return CGAffineTransformMakeTranslation(tx, 0.0f);
}

- (CGAffineTransform)parseTranslateY
{
    CGFloat ty = self.lengthValue;

    return CGAffineTransformMakeTranslation(0.0f, ty);
}

#pragma mark - Helper Methods

- (STKPXStylesheetLexeme *)advance
{
    return currentLexeme = lexer.nextLexeme;
}

- (NSString *)lexemeNameFromType:(int)type
{
    STKPXStylesheetLexeme *lexeme = [[STKPXStylesheetLexeme alloc] initWithType:type text:nil];

    return lexeme.name;
}

- (CGFloat)angleValue
{
    CGFloat result = 0.0f;

    if ([self isInTypeSet:ANGLE_SET])
    {
        switch (currentLexeme.type)
        {
            case STKPXTransformToken_NUMBER:
            {
                NSNumber *number = currentLexeme.value;

                result = DEGREES_TO_RADIANS(number.floatValue);
                break;
            }

            case STKPXTransformToken_ANGLE:
            {
                STKPXDimension *angle = currentLexeme.value;

                result = angle.radians.number;
                break;
            }

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized token type in LENGTH_SET: %@", currentLexeme];
                [self errorWithMessage:message];
                break;
            }
        }

        [self advance];
        [self advanceIfIsType:STKPXTransformToken_COMMA];
    }

    return result;
}

- (CGFloat)floatValue
{
    CGFloat result = 0.0f;

    if ([self isType:STKPXTransformToken_NUMBER])
    {
        NSNumber *number = currentLexeme.value;

        result = number.floatValue;

        [self advance];
        [self advanceIfIsType:STKPXTransformToken_COMMA];
    }
    else
    {
        [self errorWithMessage:@"Expected a NUMBER token"];
    }

    return result;
}

- (CGFloat)lengthValue
{
    CGFloat result = 0.0f;

    if ([self isInTypeSet:LENGTH_SET])
    {
        switch (currentLexeme.type)
        {
            case STKPXTransformToken_NUMBER:
            {
                NSNumber *number = currentLexeme.value;

                result = number.floatValue;
                break;
            }

            case STKPXTransformToken_LENGTH:
            {
                STKPXDimension *length = currentLexeme.value;

                result = length.points.number;
                break;
            }

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized token type in LENGTH_SET: %@", currentLexeme];
                [self errorWithMessage:message];
                break;
            }
        }

        [self advance];
        [self advanceIfIsType:STKPXTransformToken_COMMA];
    }
    else
    {
        [self errorWithMessage:@"Expected a LENGTH or NUMBER token"];
    }

    return result;
}

- (CGFloat)percentageValue
{
    CGFloat result = 0.0f;

    if ([self isInTypeSet:PERCENTAGE_SET])
    {
        switch (currentLexeme.type)
        {
            case STKPXTransformToken_PERCENTAGE:
            {
                STKPXDimension *percentage = currentLexeme.value;

                result = percentage.number / 100.0f;
                break;
            }

            case STKPXTransformToken_NUMBER:
            {
                NSNumber *number = currentLexeme.value;

                result = number.floatValue;
                break;
            }

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized token type in PERCENTAGE_SET: %@", currentLexeme];
                [self errorWithMessage:message];
                break;
            }
        }

        [self advance];
        [self advanceIfIsType:STKPXTransformToken_COMMA];
    }
    else
    {
        [self errorWithMessage:@"Expected a PERCENTAGE or NUMBER token"];
    }

    return result;
}

@end
