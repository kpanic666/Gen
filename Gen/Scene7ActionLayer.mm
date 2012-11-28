//
//  Scene7ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 10.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene7ActionLayer.h"

@implementation Scene7ActionLayer

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
        
        // add RedCells
        cellPos = ccp(screenSize.width*0.5, screenSize.height*0.75);
        RedCell *redCell1 = [self createRedCellInWorld:world position:cellPos name:@"redCell1" withPinAtPos:cellPos];
        [redCell1 setMotorSpeed:2.5];
        cellPos = ccp(screenSize.width*0.5, screenSize.height*0.25);
        RedCell *redCell2 = [self createRedCellInWorld:world position:cellPos name:@"redCell1" withPinAtPos:cellPos];
        [redCell2 setMotorSpeed:-2.5];
    }
    return self;
}

@end
