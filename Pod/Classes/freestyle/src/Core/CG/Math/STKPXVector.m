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
//  PXVector.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXVector.h"
#import "PXMath.h"

@implementation STKPXVector

@synthesize x, y;

#pragma mark - Static Initializers

+ (instancetype)vectorWithX:(CGFloat)x Y:(CGFloat)y
{
    return [[STKPXVector alloc] initWithX:x Y:y];
}

+ (instancetype)vectorWithStartPoint:(CGPoint)p1 EndPoint:(CGPoint)p2
{
    return [STKPXVector vectorWithX:p2.x - p1.x Y:p2.y - p1.y];
}

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithX:0 Y:0];
}

- (instancetype)initWithX:(CGFloat)anX Y:(CGFloat)aY
{
    if (self = [super init])
    {
        self->x = anX;
        self->y = aY;
    }

    return self;
}

#pragma mark - Getters

- (CGFloat)angle
{
    CGFloat result = ATAN2(self.y, self.x);

    return (result >= 0) ? result : result + 2 * M_PI;
}

- (CGFloat)length
{
    return SQRT(self.magnitude);
}

- (CGFloat)magnitude
{
    return x*x + y*y;
}

- (STKPXVector *)perp
{
    return [STKPXVector vectorWithX:-y Y:x];
}

- (STKPXVector *)unit
{
    return [self divide:self.length];
}

#pragma mark - Methods

- (CGFloat)angleBetweenVector:(STKPXVector *)that
{
    //CGFloat cosTheta = [self dot:that] / (self.magnitude * that.magnitude);
    //
    //return acosf(cosTheta);
    return ATAN2(that.y, that.x) - ATAN2(self.y, self.x);
}

- (CGFloat)dot:(STKPXVector *)that
{
    return self->x*that->x + self->y*that->y;
}

- (CGFloat)cross:(STKPXVector *)that
{
    return self->x*that->y - self->y*that->x;
}

- (STKPXVector *)add:(STKPXVector *)that
{
    return [STKPXVector vectorWithX:self->x + that->x Y:self->y + that->y];
}

- (STKPXVector *)subtract:(STKPXVector *)that
{
    return [STKPXVector vectorWithX:self->x - that->x Y:self->y - that->y];
}

- (STKPXVector *)divide:(CGFloat)scalar
{
    return [STKPXVector vectorWithX:self->x / scalar Y:self->y / scalar];
}

- (STKPXVector *)multiply:(CGFloat)scalar
{
    return [STKPXVector vectorWithX:self->x * scalar Y:self->y * scalar];
}

- (STKPXVector *)perpendicular:(STKPXVector *)that
{
    return [self subtract:[self projectOnto:that]];
}

- (STKPXVector *)projectOnto:(STKPXVector *)that
{
    CGFloat percent = [self dot:that] / that.magnitude;

    return [that multiply:percent];
}

#pragma mark - Overrides

-(NSString *)description
{
    return [NSString stringWithFormat:@"Vector(x=%f,y=%f)", x, y];
}

@end
