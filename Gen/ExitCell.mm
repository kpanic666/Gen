//
//  ExitCell.mm
//  Gen
//
//  Created by Andrey Korikov on 22.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "ExitCell.h"


@implementation ExitCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    shape.m_radius = self.contentSize.width * 0.25 / PTM_RATIO;
    fixtureDef.shape = &shape;
    fixtureDef.filter.categoryBits = kExitCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"exitcell_idle.png"]];
        gameObjectType = kExitCellType;
        characterState = kStateIdle;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)changeState:(CharacterStates)newState
{
    
}

- (BOOL)mouseJointBegan
{
    return FALSE;
}

@end
