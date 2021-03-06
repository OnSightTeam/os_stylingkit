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
//  STKPXFileUtils.m
//  Pixate
//
//  Created by Kevin Lindsey on 12/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXFileUtils.h"

@implementation STKPXFileUtils

+ (NSString *)sourceFromResource:(NSString *)resource ofType:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:type];

    return [self sourceFromPath:path];
}

+ (NSString *)sourceFromPath:(NSString *)path
{
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
}

@end
