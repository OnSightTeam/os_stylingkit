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
//  STKPXBoundable.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/19/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The STKPXBoundable interface indicates that a class conforming to this protcol can have its bounds set and retrieved
 */
@protocol STKPXBoundable <NSObject>

/**
 *  The bounds of this rectangle
 */
@property (nonatomic) CGRect bounds;

@end
