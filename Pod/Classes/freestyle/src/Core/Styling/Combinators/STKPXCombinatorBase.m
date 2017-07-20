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
//  STKPXCombinatorBase.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 9/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXCombinatorBase.h"
#import "STKPXSpecificity.h"
#import "STKPXSourceWriter.h"

@implementation STKPXCombinatorBase

@synthesize lhs = _lhs;
@synthesize rhs = _rhs;

STK_DEFINE_CLASS_LOG_LEVEL

#pragma mark - Initializers

- (instancetype)initWithLHS:(id<STKPXSelector>)lhs RHS:(id<STKPXSelector>)rhs
{
    if (self = [super init])
    {
        self->_lhs = lhs;
        self->_rhs = rhs;
    }

    return self;
}

#pragma mark - Getters

- (NSString *)displayName
{
    // sublasses need to implement this method
    return @"<unknown>";
}

#pragma mark - Methods

- (BOOL)matches:(id<STKPXStyleable>)element
{
    DDLogError(@"The 'matches:' method should not be called and should be overridden");

    // subclasses need to implement this method
    return NO;
}

- (void)incrementSpecificity:(STKPXSpecificity *)specificity
{
    [self->_lhs incrementSpecificity:specificity];
    [self->_rhs incrementSpecificity:specificity];
}

#pragma mark - STKPXSourcEmitter Methods

- (NSString *)source
{
    STKPXSourceWriter *writer = [[STKPXSourceWriter alloc] init];

    [self sourceWithSourceWriter:writer];

    return writer.description;
}

- (void)sourceWithSourceWriter:(id)writer
{
    [writer printIndent];
    [writer print:@"("];
    [writer print:self.displayName];
    [writer printNewLine];
    [writer increaseIndent];

    [self.lhs sourceWithSourceWriter:writer];
    [writer printNewLine];
    [self.rhs sourceWithSourceWriter:writer];

    [writer print:@")"];
    [writer decreaseIndent];
}

@end
