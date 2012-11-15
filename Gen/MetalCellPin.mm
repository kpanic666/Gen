//
//  MetalCellPin.m
//  Gen
//
//  Created by Andrey Korikov on 30.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MetalCellPin.h"

@implementation MetalCellPin

- (void)createBodyAtLocation:(CGPoint)location
{
    // Add anchor body for MetalCell. Revolute joint will connect metal cell body and this body
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2CircleShape shape;
    shape.m_radius = self.contentSize.width*0.25 / PTM_RATIO;
    body->CreateFixture(&shape, 0);
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"metalcellpin.png"]];
        gameObjectType = kMetalPinType;
        characterState = kStateIdle;
        [self createBodyAtLocation:location];
    }
    return self;
}

@end
