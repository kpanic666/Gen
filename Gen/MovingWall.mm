//
//  MovingWall.m
//  Gen
//
//  Created by Andrey Korikov on 09.08.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MovingWall.h"

@implementation MovingWall

- (void)createBodyAtLocation:(CGPoint)location withGroundBody:(b2Body*)groundBody
{
    // make wall Body
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2PolygonShape shape;
    shape.SetAsBox(self.contentSize.width / 2 / PTM_RATIO, self.contentSize.height / 2 / PTM_RATIO);
    fixtureDef.shape = &shape;
    fixtureDef.filter.categoryBits = kMovingWallFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
    
    if (self.isVertical) {
        body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(90));
    }
    
    // make prismatic joint and turn on engine for wall
    b2PrismaticJointDef wallJointDef;
    b2Vec2 worldAxis(1.0f, 0.0f);
    if (self.isVertical) {
        worldAxis.Set(0.0f, 1.0f);
    }
    wallJointDef.Initialize(body, groundBody, body->GetWorldCenter(), worldAxis);
    wallJointDef.lowerTranslation = _negativeOffset;
    wallJointDef.upperTranslation = _positiveOffset;
    wallJointDef.enableLimit = true;
    wallJointDef.maxMotorForce = 50.0f;
    wallJointDef.motorSpeed = 1;
    wallJointDef.enableMotor = true;
    wallJoint = (b2PrismaticJoint*) world->CreateJoint(&wallJointDef);
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location vertical:(BOOL)vertical withGroundBody:(b2Body *)groundBody
{
    if ((self = [super init]))
    {
        world = theWorld;
        [self setIsVertical:vertical];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"movingwall_idle.png"]];
        gameObjectType = kMovingWallType;
        characterState = kStateIdle;
        self.negativeOffset = -2.0f;
        self.positiveOffset = 2.0f;
        [self createBodyAtLocation:location withGroundBody:groundBody];
    }
    return self;
}

- (void)setMovingSpeed:(float32)movingSpeed
{
    if (wallJoint->IsMotorEnabled()) {
        wallJoint->SetMotorSpeed(movingSpeed);
    }
    else {
        wallJoint->SetMaxMotorForce(1000);
        wallJoint->SetMotorSpeed(movingSpeed);
        wallJoint->EnableMotor(YES);
    }
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    float32 jTrans = wallJoint->GetJointTranslation();
    if (jTrans >= self.positiveOffset || jTrans <= self.negativeOffset) {
        [self setMovingSpeed:wallJoint->GetMotorSpeed() * -1];
    }
}

@end
