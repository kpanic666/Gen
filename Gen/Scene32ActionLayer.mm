//
//  Scene32ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene32ActionLayer.h"

@implementation Scene32ActionLayer

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
        
        // add MetalCell with Pin at Center
        cellPos = ccp(screenSize.width*0.5, screenSize.height*0.5);
        MetalCell *metalCell1 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        [metalCell1 setMotorSpeed:5.0f];
        
        [self setFlowing:b2Vec2(-4.0f, 0)];
    }
    return self;
}


@end
