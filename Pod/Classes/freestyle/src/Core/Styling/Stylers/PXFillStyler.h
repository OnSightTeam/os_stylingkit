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
//  PXFillStyler.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylerBase.h"

/**
 *  - background-color: <paint>
 *  - background-size: <size>
 *  - background-inset: <inset>
 *  - background-inset-top: <length>
 *  - background-inset-right: <length>
 *  - background-inset-bottom: <length>
 *  - background-inset-left: <length>
 *  - background-image: <url>
 *  - background-padding: <padding>
 *  - background-top-padding: <length>
 *  - background-right-padding: <length>
 *  - background-bottom-padding: <length>
 *  - background-left-padding: <length>
 */

@interface PXFillStyler : PXStylerBase

+ (PXFillStyler *)sharedInstance;

@end
