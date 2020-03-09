//
//  PhysicsSprite.mm
//  Gen
//
//  Created by Andrey Korikov on 10.03.12.
//  Copyright kpanic666@gmail.com 2012. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "Constants.h"

@interface Helper : NSObject 

/** converts a point coordinate to Box2D meters */
+(b2Vec2) toMeters:(CGPoint)point;

/** converts a PIXEL coordinate to Box2D meters */
+(b2Vec2) toMetersFromPixels:(CGPoint)point;

/** converts a box2d position to point coordinates */
+(CGPoint) toPoints:(b2Vec2)vec;

/** converts a box2d position to PIXEL coordinates */
+(CGPoint) toPixels:(b2Vec2)vec;

/** returns the pixels-to-meter ratio scaled to the device's pixel size */
+(float) pixelsToMeterRatio;

+(CGPoint) locationFromTouch:(UITouch*)touch;
+(CGPoint) locationFromTouches:(NSSet*)touches;

+(CGPoint) screenCenter;
+(CGPoint) convertPosition:(CGPoint)point;
+(float) convertFontSize:(float)fontSize;

@end
