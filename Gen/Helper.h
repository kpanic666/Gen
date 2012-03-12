//
//  PhysicsSprite.mm
//  Gen
//
//  Created by Andrey Korikov on 10.03.12.
//  Copyright kpanic666@gmail.com 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "Constants.h"

@interface Helper : NSObject 
{
}

+(b2Vec2) toMeters:(CGPoint)point;
+(CGPoint) toPoints:(b2Vec2)vec;

+(CGPoint) locationFromTouch:(UITouch*)touch;
+(CGPoint) locationFromTouches:(NSSet*)touches;

+(CGPoint) screenCenter;

@end
