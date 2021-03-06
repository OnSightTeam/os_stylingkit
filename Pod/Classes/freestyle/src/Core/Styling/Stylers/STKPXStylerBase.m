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
//  STKPXStylerBase.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXStylerBase.h"
#import "UIView+STKPXStyling.h"
#import "STKPXPseudoClassSelector.h"

@implementation STKPXStylerBase

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithCompletionBlock:nil];
}

- (instancetype)initWithCompletionBlock:(STKPXStylerCompletionBlock)block
{
    if (self = [super init])
    {
        _completionBlock = block;
    }

    return self;
}

#pragma mark - Helper Methods

- (NSDictionary *)declarationHandlers
{
    // Subclasses need to implement this
    return nil;
}

#pragma mark - STKPXStyler Implementation

- (NSArray *)supportedProperties
{
    return self.declarationHandlers.allKeys;
}

- (void)processDeclaration:(STKPXDeclaration *)declaration withContext:(STKPXStylerContext *)context
{
    STKPXDeclarationHandlerBlock block = [self declarationHandlers][declaration.name];

    if (block)
    {
        block(declaration, context);
    }
}

- (void)applyStylesWithContext:(STKPXStylerContext *)context
{
    if (self.completionBlock)
    {
        self.completionBlock(context.styleable, self, context);
    }
}

@end
