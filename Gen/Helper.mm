//
//  PhysicsSprite.mm
//  Gen
//
//  Created by Andrey Korikov on 10.03.12.
//  Copyright kpanic666@gmail.com 2012. All rights reserved.
//


#import "Helper.h"


@implementation Helper


// convenience method to convert a CGPoint to a b2Vec2
+(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
+(CGPoint) toPoints:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

+(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

+(CGPoint) screenCenter
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	return CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
}

@end