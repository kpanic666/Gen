//
//  MovingWall.h
//  Gen
//  Представляет из себя игровые препятствия в виде стенок двигающихся туда, сюда
//  Created by Andrey Korikov on 09.08.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface MovingWall : Box2DSprite
{
    BOOL _isVertical;                        // Если 1 - то располагается и движется вертикально. По умолчанию - горизонтально.
    float32 _movingSpeed;                   // Скорость с которой препятствие двигается туда-сюда
    float32 _negativeOffset, _positiveOffset;     // negativeOffset - всегда <= 0, positiveOffset - всегда >= 0. Смещения относительно изначального положения, к которым будет попеременно двигаться препятствие. В метрах
    b2PrismaticJoint *wallJoint;
}

@property (nonatomic) BOOL isVertical;
@property (nonatomic) float32 movingSpeed;
@property (nonatomic) float32 negativeOffset;
@property (nonatomic) float32 positiveOffset;

+(id) wallWithWorld:(b2World*)theWorld location:(CGPoint)location isVertical:(BOOL)vertical withGroundBody:(b2Body*)groundBody;
+(id) wallWithWorld:(b2World *)theWorld location:(CGPoint)location isVertical:(BOOL)vertical withGroundBody:(b2Body *)groundBody negOffset:(float32)negOffset posOffset:(float32)posOffset speed:(float32)speed;
-(id) initWithWorld:(b2World*)theWorld location:(CGPoint)location isVertical:(BOOL)vertical withGroundBody:(b2Body*)groundBody negOffset:(float32)negOffset posOffset:(float32)posOffset speed:(float32)speed;

@end
