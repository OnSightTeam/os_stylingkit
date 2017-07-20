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
//  STKPXStylerBase.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXStyler.h"
#import "STKPXStylerContext.h"

/**
 *  A typedef for the block that will be called once this styler is ready to be applied to a control
 *
 *  @param view The view to be styled
 *  @param styler The styler to use when styling the view
 *  @param context Any additional context associated with this styling cycle
 */
typedef void(^STKPXStylerCompletionBlock)(id<STKPXStyleable> view, id<STKPXStyler> styler, STKPXStylerContext *context);

/**
 *  A typedef for the block that will be called for a given property.
 *
 *  @param declaration The declaration to process
 *  @param context Any additional context associated with this styling cycle
 */
typedef void(^STKPXDeclarationHandlerBlock)(STKPXDeclaration *declaration, STKPXStylerContext *context);

/**
 *  A common base clase to simplify implementation of new stylers
 */
@interface STKPXStylerBase : NSObject <STKPXStyler>

/**
 *  A read-only property that returns the completion block associated with this styler
 */
@property (nonatomic, readonly) STKPXStylerCompletionBlock completionBlock;

- (instancetype)init;

/**
 *  Initialize a newly allocated instance.
 *
 *  @param block A block to invoke to apply styling from this styler
 */
-(instancetype)initWithCompletionBlock:(STKPXStylerCompletionBlock)block NS_DESIGNATED_INITIALIZER;

@end
