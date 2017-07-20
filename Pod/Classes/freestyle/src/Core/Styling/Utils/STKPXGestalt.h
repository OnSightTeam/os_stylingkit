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
//  STKPXGestalt.h
//  Pixate
//
//  Created by Giovanni Donelli on 8/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// ---
// Version

typedef struct {
    int16_t primary;
    int16_t secondary;
    int16_t tertiary;
}
STKPXVersionType;

STKPXVersionType STKPXVersionFromObject(id value);
STKPXVersionType STKPXVersionFromString(NSString* vString);
NSString* NSStringFromPXVersion(STKPXVersionType v);

int16_t STKPXVersionPrimary(STKPXVersionType v);
int16_t STKPXVersionSecondary(STKPXVersionType v);
int16_t STKPXVersionTertiary(STKPXVersionType v);

// v1 >  v2 : return > 0
// v1 <  v2 : return < 0
// v1 == v2 : return 0

NSComparisonResult STKPXVersionCompare(STKPXVersionType v1, STKPXVersionType v2);

// if base is:
//
//    1. 4 (base) means matches all 4 (testVersion)
//    1. 4.1 (base) means matches 4.1 and any 4.1.x but no other 4.x (testVersion)

BOOL STKPXVersionMatch(STKPXVersionType base, STKPXVersionType testVersion);

STKPXVersionType STKPXVersionCurrentSystem();

// ---
// Aspect ratio: (dividend / divisor) = quotient

typedef CGFloat STKPXScreenRatioType;

STKPXScreenRatioType STKPXScreenRatioFromString(NSString* ratioString);
STKPXScreenRatioType STKPXScreenRatioFromObject(id object);
NSComparisonResult STKPXScreenRatioCompare(STKPXScreenRatioType ratio1, STKPXScreenRatioType ratio2);

STKPXScreenRatioType STKPXScreenRatioCurrentSystem();
