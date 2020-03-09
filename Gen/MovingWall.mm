//
//  MovingWall.m
//  Gen
//
//  Created by Andrey Korikov on 09.08.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MovingWall.h"

@implementation MovingWall
{
    double timeAccum;
}

+(id) wallWithWorld:(b2World *)theWorld location:(CGPoint)location isVertical:(BOOL)vertical withGroundBody:(b2Body *)groundBody
{
    return [[[self alloc] initWithWorld:theWorld location:location isVertical:vertical withGroundBody:groundBody negOffset:-1.0f posOffset:1.0f speed:1] autorelease];
}

+(id) wallWithWorld:(b2World *)theWorld location:(CGPoint)location isVertical:(BOOL)vertical withGroundBody:(b2Body *)groundBody negOffset:(float32)negOffset posOffset:(float32)posOffset speed:(float32)speed
{
    return [[[self alloc] initWithWorld:theWorld location:location isVertical:vertical withGroundBody:groundBody negOffset:negOffset posOffset:posOffset speed:speed] autorelease];
}

- (id)initWithWorld:(b2World *)theWorld location:(CGPoint)location isVertical:(BOOL)vertical withGroundBody:(b2Body *)groundBody negOffset:(float32)negOffset posOffset:(float32)posOffset speed:(float32)speed
{
    if ((self = [super init]))
    {
        world = theWorld;
        [self setIsVertical:vertical];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"movingwall%i.png", (int)random() % 2 + 1]]];
        gameObjectType = kMovingWallType;
        characterState = kStateTraveling;
        _negativeOffset = negOffset;
        _positiveOffset = posOffset;
        _movingSpeed = speed;
        timeAccum = 0;
        [self createBodyAtLocation:location withGroundBody:groundBody];
    }
    return self;
}

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
    fixtureDef.density = 2.0f;
    fixtureDef.friction = 5.0f;
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
    wallJointDef.maxMotorForce = 100.0f;
    wallJointDef.motorSpeed = _movingSpeed;
    wallJointDef.enableMotor = true;
    wallJoint = (b2PrismaticJoint*) world->CreateJoint(&wallJointDef);
}

- (void)setMovingSpeed:(float32)movingSpeed
{
    _movingSpeed = movingSpeed;
    
    if (wallJoint->IsMotorEnabled()) {
        wallJoint->SetMotorSpeed(movingSpeed);
    }
    else {
        wallJoint->SetMaxMotorForce(100);
        wallJoint->SetMotorSpeed(movingSpeed);
        wallJoint->EnableMotor(YES);
    }
}

-(void) setNegativeOffset:(float32)negativeOffset
{
    _negativeOffset = negativeOffset;
    wallJoint->SetLimits(negativeOffset, wallJoint->GetUpperLimit());
}

-(void) setPositiveOffset:(float32)positiveOffset
{
    _positiveOffset = positiveOffset;
    wallJoint->SetLimits(wallJoint->GetLowerLimit(), positiveOffset);
}

- (void)reversMovingDirection
{
    [self setMovingSpeed:wallJoint->GetMotorSpeed() * -1];
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    float32 jTrans = wallJoint->GetJointTranslation();

    // Если MovingWall достигла конца пути, то двигаем в обратную сторону
    if (jTrans >= self.positiveOffset || jTrans <= self.negativeOffset) {
        [self reversMovingDirection];
        timeAccum = 0;
    }
    else
    {
        // Если MovingWall зажала какой то предмет и находится на перепутье больше 5 сек - освобождаем
        timeAccum += deltaTime;
        if (timeAccum > 4.0) {
            [self reversMovingDirection];
            timeAccum = 0;
        }
    }
}

@end
