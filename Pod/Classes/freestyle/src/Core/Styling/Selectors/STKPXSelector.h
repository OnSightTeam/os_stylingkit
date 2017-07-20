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
//  STKPXSelector.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXStyleable.h"
#import "STKPXSourceEmitter.h"
#import "STKPXSpecificity.h"

/**
 *  The STKPXElementMatcher protocol defines a method used to determine if a given object matches a specific selector
 *  expression as captured by the class the conforms to this protocol.
 */
@protocol STKPXSelector <STKPXSourceEmitter>

/**
 *  Determine if the specified element matches this STKPXElementMatcher
 */
- (BOOL)matches:(id<STKPXStyleable>)element;

/**
 *  Update the specified STKPXSpecificity instance as is appropriate for the class that conforms to this protocol
 */
- (void)incrementSpecificity:(STKPXSpecificity *)specificity;

@end
