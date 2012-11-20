//
//  Scene35ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene35ActionLayer.h"
#import "SimpleQueryCallback.h"

@interface Scene35ActionLayer()
{
    MetalCell *metalCell1;
    MetalCell *metalCell2;
    MetalCell *metalCell3;
}

@end

@implementation Scene35ActionLayer

- (void)makeFireShot
{
    metalCell2.body->ApplyAngularImpulse(100);
    metalCell3.body->ApplyLinearImpulse(b2Vec2(100,0), metalCell3.body->GetLocalCenter());
    CCLOG(@"FireSHOT");
}

- (void)monitoringOfClutch
{
    if (metalCell1.body->GetAngle() <= CC_DEGREES_TO_RADIANS(-20) && metalCell2.body->GetAngle() <= CC_DEGREES_TO_RADIANS(0) && metalCell3.body->GetLinearVelocity() == b2Vec2_zero) {
        [self makeFireShot];
    }
}

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint pinPos;
        CGPoint cellPos;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background2.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add MetalCells
        // Курок
        cellPos = [Helper convertPosition:ccp(244, 387)];
        pinPos = [Helper convertPosition:ccp(218, 359)];
        metalCell1 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:pinPos];
        metalCell1.pinJoint->SetLimits(CC_DEGREES_TO_RADIANS(0), CC_DEGREES_TO_RADIANS(25));
        metalCell1.pinJoint->EnableLimit(YES);
        [metalCell1 setMotorSpeed:-50];
        metalCell1.pinJoint->SetMaxMotorTorque(1);
        // Set filter properties
        b2Filter filter;
        for (b2Fixture *f = metalCell1.body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.maskBits = kChildCellFilterCategory;
            f->SetFilterData(filter);
        }
        // Затвор
        cellPos = [Helper convertPosition:ccp(452, 300)];
        pinPos = [Helper convertPosition:ccp(452, 256)];
        metalCell2 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell2" withPinAtPos:pinPos];
        metalCell2.pinJoint->SetLimits(CC_DEGREES_TO_RADIANS(-90), CC_DEGREES_TO_RADIANS(0));
        metalCell2.pinJoint->EnableLimit(YES);
        [metalCell2 setMotorSpeed:1];
        for (b2Fixture *f = metalCell2.body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.maskBits = kChildCellFilterCategory;
            f->SetFilterData(filter);
        }
        
        // Бойок
        cellPos = [Helper convertPosition:ccp(76, 303)];
        metalCell3 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell3"];
        b2PrismaticJointDef prismJD;
        prismJD.Initialize(groundBody, metalCell3.body, metalCell3.body->GetWorldCenter(), b2Vec2(1.0f, 0));
        prismJD.lowerTranslation = 0.0f;
        prismJD.upperTranslation = 5.0f;
        prismJD.enableLimit = true;
        prismJD.motorSpeed = -160.0f;
        prismJD.maxMotorForce = 2;
        prismJD.enableMotor = true;
        world->CreateJoint(&prismJD);
        
        // Create moving wall
        cellPos = [Helper convertPosition:ccp(845, 369)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:-7.0f posOffset:0 speed:4];
        
        [self schedule:@selector(monitoringOfClutch) interval:0.2f];
    }
    return self;
}

- (BOOL)clutchTapCheckAtLoc:(b2Vec2)locationWorld
{
    b2AABB aabb;
    b2Vec2 delta = b2Vec2(1.0/PTM_RATIO, 1.0/PTM_RATIO);
    aabb.lowerBound = locationWorld - delta;
    aabb.upperBound = locationWorld + delta;
    SimpleQueryCallback callback(locationWorld, nil, kMetalType);
    world->QueryAABB(&callback, aabb);
    
    if (callback.fixtureFound)
    {
        b2Body *foundBody = callback.fixtureFound->GetBody();
        if (foundBody == metalCell1.body) {
            metalCell1.body->ApplyAngularImpulse(-50);
            return true;
        }
    }
    return false;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    [self clutchTapCheckAtLoc:locationWorld];
    [super ccTouchBegan:touch withEvent:event];
    
    return TRUE;
}


@end
