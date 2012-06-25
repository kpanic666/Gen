//
//  DrawingSmoothPrimitives.h
//  Gen
//
//  Created by Andrey Korikov on 15.06.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#ifndef DRAWING_SMOOTH_PRIMITIVES_H
#define DRAWING_SMOOTH_PRIMITIVES_H

#import <Foundation/Foundation.h>

#import "ccTypes.h"
#import "ccMacros.h"

#ifdef __CC_PLATFORM_IOS
#import <CoreGraphics/CGGeometry.h>	// for CGPoint
#endif


#ifdef __cplusplus
extern "C" {
#endif
    
/** draw anti-aliased line */
void drawSmoothLine( CGPoint origin, CGPoint destination, float width );
    
/** set the drawing color with 4 unsigned bytes */
void drawColor4B(ccColor4B color);

#ifdef __cplusplus
}
#endif

#endif // DRAWING_SMOOTH_PRIMITIVES_H
