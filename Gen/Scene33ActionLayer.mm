//
//  Scene33ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene33ActionLayer.h"

@implementation Scene33ActionLayer

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
        
        // add MetalCells
        cellPos = [Helper convertPosition:ccp(434, 484)];
        MetalCell *metalCell1 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell1"];
        cellPos = [Helper convertPosition:ccp(535, 171)];
        MetalCell *metalCell2 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell1"];
        // Create Prismatic Joints
        // Bottom Wall
        b2PrismaticJointDef wallPrismJD;
        b2Vec2 worldAxis(0.0f, 1.0f);
        wallPrismJD.Initialize(groundBody, metalCell1.body, metalCell1.body->GetWorldCenter(), worldAxis);
        wallPrismJD.lowerTranslation = -2.0f;
        wallPrismJD.upperTranslation = 1.0f;
        wallPrismJD.enableLimit = true;
        b2PrismaticJoint *wall1PrismJ = (b2PrismaticJoint*) world->CreateJoint(&wallPrismJD);
        // Top
        wallPrismJD.Initialize(groundBody, metalCell2.body, metalCell2.body->GetWorldCenter(), worldAxis);
        wallPrismJD.lowerTranslation = -1.0f;
        wallPrismJD.upperTranslation = 2.0f;
        wallPrismJD.enableLimit = true;
        b2PrismaticJoint *wall2PrismJ = (b2PrismaticJoint*) world->CreateJoint(&wallPrismJD);
        // Create Gear Joints
        b2GearJointDef wallGearJD;
        wallGearJD.bodyA = metalCell1.body;
        wallGearJD.bodyB = metalCell2.body;
        wallGearJD.joint1 = wall1PrismJ;
        wallGearJD.joint2 = wall2PrismJ;
        wallGearJD.ratio = -1.0f;
        world->CreateJoint(&wallGearJD);
        
        
    }
    return self;
}


@end
