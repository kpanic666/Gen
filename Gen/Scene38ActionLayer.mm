//
//  Scene38ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene38ActionLayer.h"

@implementation Scene38ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background2.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        [self setFlowing:b2Vec2(9.0f, 0)];
        
        // Add moving metal cell, that will move slowly to the left
        cellPos = [Helper convertPosition:ccp(920, 320)];
        MetalCell *metalCell1 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell1"];
        b2PrismaticJointDef prismJD;
        prismJD.Initialize(groundBody, metalCell1.body, metalCell1.body->GetWorldCenter(), b2Vec2(1.0f, 0));
        prismJD.lowerTranslation = -12.0f;
        prismJD.upperTranslation = 0.0f;
        prismJD.enableLimit = true;
        prismJD.motorSpeed = -0.5f;
        prismJD.maxMotorForce = 100;
        prismJD.enableMotor = true;
        world->CreateJoint(&prismJD);
        
        [self schedule:@selector(createBombCellAtRandomLocation) interval:1.5];
        
    }
    return self;
}

- (void)createBombCellAtRandomLocation
{
    BOOL upSide = CCRANDOM_0_1() < 0.5f;
    CGPoint randLoc;
    float yOffset = 50;
    upSide ? randLoc = ccp(0, screenSize.height * 0.5 + yOffset) : randLoc = ccp(0, screenSize.height * 0.5 - yOffset);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (upSide) {
            randLoc = ccpAdd(randLoc, ccp(32, 64));
        }
        else
        {
            randLoc = ccpAdd(randLoc, ccp(32, -64));
        }
    }
    BombCell *bombCell = [[[BombCell alloc] initWithWorld:world atLocation:randLoc] autorelease];
    [bombCell setDontCount:YES];
    [sceneSpriteBatchNode addChild:bombCell z:1];
    [bombCell changeState:kStateConnected];
}

@end
