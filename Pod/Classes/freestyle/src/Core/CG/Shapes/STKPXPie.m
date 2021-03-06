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
//  STKPXPie.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/5/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXPie.h"
#import "STKPXMath.h"

@implementation STKPXPie

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat startingRadians = DEGREES_TO_RADIANS(self.startingAngle);
    CGFloat endingRadians = DEGREES_TO_RADIANS(self.endingAngle);

    CGPathMoveToPoint(path, NULL, self.center.x, self.center.y);
    CGPathAddArc(path, NULL, self.center.x, self.center.y, self.radius, startingRadians, endingRadians, NO);
    CGPathCloseSubpath(path);

    CGPathRef resultPath = CGPathCreateCopy(path);
    CGPathRelease(path);

    return resultPath;
}

@end
