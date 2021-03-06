/*
 * Copyright 2015-present StylingKit Development Team. All rights reserved..
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
// Created by Anton Matosov on 1/5/16.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UIAlertView supports the following element name:
 *
 *  - alert-view
 *
 *  UIActionSheet supports the following properties:
 *
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *  - STKPXAnimationStyler
 *
 */
@interface STK_UIAlertControllerView : UIView

+ (Class)targetSuperclass;

@end
