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
//  STKPXTitaniumMacros.h
//  Pixate
//
//  Created by Paul Colton on 10/7/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#ifndef Pixate_PXTitaniumMacros_h
#define Pixate_PXTitaniumMacros_h

#import "STKPXMacrosCommon.h"

// Native method wrappers with Titanium support

#define IF_CHECK_LOGIC ![PixateFreestyle sharedInstance].titaniumMode || (self.styleId == nil && self.styleClass == nil && self.styleCSS == nil)

//
// STKPX_WRAP_PROP
//

#define STKPX_WRAP_PROP(TT,A) STKPX_PXWRAP_PROP(TT,A); STKPX_TIWRAP_PROP(TT,A);
#define STKPX_PXWRAP_PROP(TT,A) -(TT *) px_##A { return (__bridge TT *)callSuper0(SUPER_PREFIX, @selector(A)); }
#define STKPX_TIWRAP_PROP(TT,A) -(TT *) A { if(IF_CHECK_LOGIC) { return [self px_##A]; } return nil; }

//
// STKPX_WRAP_1
//

#define STKPX_WRAP_1(A,AA) STKPX_PXWRAP_1(A,AA); STKPX_TIWRAP_1(A,AA);
#define STKPX_PXWRAP_1(A,AA) -(void) px_##A:(id)AA  { callSuper1(SUPER_PREFIX, @selector(A:), AA); }
#define STKPX_TIWRAP_1(A,AA) -(void) A:(id)AA { if(IF_CHECK_LOGIC) { [self px_##A:AA]; } }

//
// STKPX_WRAP_1v
//

#define STKPX_WRAP_1v(A,TT,AA) STKPX_PXWRAP_1v(A,TT,AA); STKPX_TIWRAP_1v(A,TT,AA);
#define STKPX_PXWRAP_1v(A,TT,AA) -(void) px_##A:(TT)AA  { callSuper1v(SUPER_PREFIX, @selector(A:), (void *) AA); }
#define STKPX_TIWRAP_1v(A,TT,AA) -(void) A:(TT)AA { if(IF_CHECK_LOGIC) { [self px_##A:AA]; } }

//
// STKPX_WRAP_1b
//

#define STKPX_WRAP_1b(A,AA) STKPX_PXWRAP_1b(A,AA); STKPX_TIWRAP_1b(A,AA);
#define STKPX_PXWRAP_1b(A,AA) -(void) px_##A:(BOOL)AA  { callSuper1b(SUPER_PREFIX, @selector(A:), AA); }
#define STKPX_TIWRAP_1b(A,AA) -(void) A:(BOOL)AA { if(IF_CHECK_LOGIC) { [self px_##A:AA]; } }


//
// STKPX_WRAP_1s (s = struct)
// A = method
// TT = param type
// AA = param
//

#define STKPX_WRAP_1s(A,TT,AA) STKPX_PXWRAP_1s(A,TT,AA); STKPX_TIWRAP_1s(A,TT,AA);
#define STKPX_PXWRAP_1s(A,TT,AA) -(void) px_##A:(TT)AA  { CALL_SUPER1(self, [self pxClass], @selector(A:), TT, AA); }
#define STKPX_TIWRAP_1s(A,TT,AA) -(void) A:(TT)AA { if(IF_CHECK_LOGIC) { [self px_##A:AA]; } }

//
// STKPX_WRAP_2
//

#define STKPX_WRAP_2(A,AA,B,BB) STKPX_PXWRAP_2(A,AA,B,BB); STKPX_TIWRAP_2(A,AA,B,BB);
#define STKPX_PXWRAP_2(A,AA,B,BB) -(void) px_##A:(id)AA B:(id)BB { callSuper2(SUPER_PREFIX, @selector(A:B:), AA, BB); }
#define STKPX_TIWRAP_2(A,AA,B,BB) -(void) A:(id)AA B:(id)BB { if(IF_CHECK_LOGIC) { [self px_##A:AA B:BB]; } }


//
// STKPX_WRAP_2v
//

#define STKPX_WRAP_2v(A,AA,B,TT,BB) STKPX_PXWRAP_2v(A,AA,B,TT,BB); STKPX_TIWRAP_2v(A,AA,B,TT,BB);
#define STKPX_PXWRAP_2v(A,AA,B,TT,BB) -(void) px_##A:(id)AA B:(TT)BB { callSuper2v(SUPER_PREFIX, @selector(A:B:), AA, (void *) BB); }
#define STKPX_TIWRAP_2v(A,AA,B,TT,BB) -(void) A:(id)AA B:(TT)BB { if(IF_CHECK_LOGIC) { [self px_##A:AA B:BB]; } }

//
// STKPX_WRAP_2vv
//

#define STKPX_WRAP_2vv(A,T,AA,B,TT,BB) STKPX_PXWRAP_2vv(A,T,AA,B,TT,BB); STKPX_TIWRAP_2vv(A,T,AA,B,TT,BB);
#define STKPX_PXWRAP_2vv(A,T,AA,B,TT,BB) -(void) px_##A:(T)AA B:(TT)BB { callSuper2vv(SUPER_PREFIX, @selector(A:B:), &AA, (void *) BB); }
#define STKPX_TIWRAP_2vv(A,T,AA,B,TT,BB) -(void) A:(T)AA B:(TT)BB { if(IF_CHECK_LOGIC) { [self px_##A:AA B:BB]; } }


//
// STKPX_WRAP_3v
//

#define STKPX_WRAP_3v(A,AA,B,TT,BB,C,TTT,CC) STKPX_PXWRAP_3v(A,AA,B,TT,BB,C,TTT,CC); STKPX_TIWRAP_3v(A,AA,B,TT,BB,C,TTT,CC);
#define STKPX_PXWRAP_3v(A,AA,B,TT,BB,C,TTT,CC) -(void) px_##A:(id)AA B:(TT)BB C:(TTT)CC { callSuper3v(SUPER_PREFIX, @selector(A:B:C:), AA, (void *) BB, (void *)CC); }
#define STKPX_TIWRAP_3v(A,AA,B,TT,BB,C,TTT,CC) -(void) A:(id)AA B:(TT)BB C:(TTT)CC { if(IF_CHECK_LOGIC) { [self px_##A:AA B:BB C:CC]; } }

//
// STKPX_WRAP_4v
//

#define STKPX_WRAP_4v(A,AA,B,TT,BB,C,TTT,CC,D,TTTT,DD) STKPX_PXWRAP_4v(A,AA,B,TT,BB,C,TTT,CC,D,TTTT,DD); STKPX_TIWRAP_4v(A,AA,B,TT,BB,C,TTT,CC,D,TTTT,DD);
#define STKPX_PXWRAP_4v(A,AA,B,TT,BB,C,TTT,CC,D,TTTT,DD) -(void) px_##A:(id)AA B:(TT)BB C:(TTT)CC D:(TTTT)DD { callSuper4v(SUPER_PREFIX, @selector(A:B:C:D:), AA, (void *) BB, (void *)CC, (void *)DD); }
#define STKPX_TIWRAP_4v(A,AA,B,TT,BB,C,TTT,CC,D,TTTT,DD) -(void) A:(id)AA B:(TT)BB C:(TTT)CC D:(TTTT)DD { if(IF_CHECK_LOGIC) { [self px_##A:AA B:BB C:CC D:DD]; } }

/* Not used right now
 #ifndef TITANIUM
 
 #undef STKPX_TIWRAP_PROP
 #define STKPX_TIWRAP_PROP(TT,A)
 
 #undef STKPX_TIWRAP_1
 #define STKPX_TIWRAP_1(A,AA)
 
 #undef STKPX_TIWRAP_1v
 #define STKPX_TIWRAP_1v(A,TT,AA)
 
 #undef STKPX_TIWRAP_1b
 #define STKPX_TIWRAP_1b(A,AA)
 
 #undef STKPX_TIWRAP_1s
 #define STKPX_TIWRAP_1s(A,TT,AA)
 
 #undef STKPX_TIWRAP_2
 #define STKPX_TIWRAP_2(A,AA,B,BB)
 
 #undef STKPX_TIWRAP_2v
 #define STKPX_TIWRAP_2v(A,AA,B,TT,BB)
 
 #undef STKPX_TIWRAP_2fv
 #define STKPX_TIWRAP_2fv(A,T,AA,B,TT,BB)
 
 #undef STKPX_TIWRAP_3v
 #define STKPX_TIWRAP_3v(A,AA,B,TT,BB,C,TTT,CC)
 
 #undef STKPX_TIWRAP_4v
 #define STKPX_TIWRAP_4v(A,AA,B,TT,BB,C,TTT,CC,D,TTTT,DD)
 
 #endif // TITANIUM
 */

#endif // Pixate_PXTitaniumMacros_h

