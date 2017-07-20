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
//  STKPXScene.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXRenderable.h"

@class STKPXShapeView;

/**
 *  A top-level container for STKPXShapes. This is used to define the bounds of a set of STKPXShapes. It also is a centralized
 *  container for all shape ids allowing you to retrieve shapes in a scene by their id.
 */
@interface STKPXShapeDocument : NSObject <STKPXRenderable>

/**
 *  The bounds of the shapes in this scene
 */
@property (nonatomic) CGRect bounds;

/**
 *  The top-level shape rendered by this scene.
 *
 *  If a collection of shapes are needed, then this shape will need to be a STKPXShapeGroup
 */
@property (nonatomic, strong) id<STKPXRenderable> shape;

/**
 *  The top-level view that this scene belongs to
 */
@property (nonatomic, strong) STKPXShapeView *parentView;

/**
 *  Return the shape in this scene with the specfied name.
 *
 *  @param name The name of the shape
 *  @returns A STKPXRenderable or nil
 */
- (id<STKPXRenderable>)shapeForName:(NSString *)name;

/**
 *  Register a shape with the specified name with this scene.
 *
 *  @param shape The shape to register
 *  @param name The shape's name
 */
- (void)addShape:(id<STKPXRenderable>)shape forName:(NSString *)name;

@end
