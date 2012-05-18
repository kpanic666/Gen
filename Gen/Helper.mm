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

// Конвертирует точку из координат iPhoneRetina в любые другие в зависимости от устройства на котором вызывается
+(CGPoint) convertPosition:(CGPoint)point
{
    point = ccp(point.x, 640-point.y);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return ccpMult(point, 0.5);
    }
    else
    {
        // Центрируем все объекты на экране iPad, используя координаты для iPhone.
        return ccpAdd(point, ccp(32, 64));
    }
}

+(float) convertFontSize:(float)fontSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return fontSize * 2;
    } else {
        return fontSize;
    }
}

@end
