//
//  RedCell.m
//  Gen
//
//  Created by Andrey Korikov on 02.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "RedCell.h"

@implementation RedCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    shape.m_radius = [self boundingBox].size.width * 0.5 / PTM_RATIO;
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
        gameObjectType = kEnemyTypeRedCell;
        characterState = kStateIdle;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)changeState:(CharacterStates)newState
{
    
}


@end
