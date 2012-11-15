//
//  Scene14ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 15.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene14ActionLayer.h"
#import "MetalCell.h"

@implementation Scene14ActionLayer

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

        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(480, 300)];
        CGPoint pinPos = [Helper convertPosition:ccp(481, 421)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:pinPos];
        [self addChild:metalCell1 z:1];
        [self addChild:metalCell1.pin z:2];
    }
    return self;
}

@end
