//
//  Scene34ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene34ActionLayer.h"

@implementation Scene34ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Add metal cells
        cellPos = [Helper convertPosition:ccp(543, 202)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(269, 221)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell2" withPinAtPos:cellPos];
        
        // Add red cell
        cellPos = [Helper convertPosition:ccp(688, 320)];
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        redCell1.body->SetType(b2_dynamicBody);
        [self addChild:redCell1 z:-1];
        // Set filter properties
        b2Filter filter;
        for (b2Fixture *f = redCell1.body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.maskBits = kChildCellFilterCategory | kMetalCellFilterCategory;
            f->SetFilterData(filter);
        }
        // Create prismatic joint for redCell. Only lift up and always try to fall down
        b2PrismaticJointDef redPrismJD;
        redPrismJD.Initialize(groundBody, redCell1.body, redCell1.body->GetWorldCenter(), b2Vec2(0, 1.0f));
        redPrismJD.lowerTranslation = 0.0f;
        redPrismJD.upperTranslation = 25.0f;
        redPrismJD.enableLimit = true;
        redPrismJD.motorSpeed = -3.5f;
        redPrismJD.maxMotorForce = 8;
        redPrismJD.enableMotor = true;
        world->CreateJoint(&redPrismJD);
    }
    return self;
}


@end
