//
//  Scene5ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 01.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene5ActionLayer.h"

@implementation Scene5ActionLayer

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
        cellPos = [Helper convertPosition:ccp(442, 331)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        
        // Add Tutorial text and arrows
        CCSprite *info = [CCSprite spriteWithSpriteFrameName:@"tut_arrow1.png"];
        info.position = [Helper convertPosition:ccp(503, 278)];
        info.opacity = 0;
        info.flipY = YES;
        info.rotation = 90;
        [sceneSpriteBatchNode addChild:info z:-2];
        CCLabelTTF *infoText = [CCLabelTTF labelWithString:@"Some objects\n can be moved" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        infoText.color = ccBLACK;
        infoText.opacity = 0;
        infoText.position = ccp(info.position.x + info.contentSize.width*0.7 + infoText.contentSize.width*0.5, info.position.y);
        [self addChild:infoText z:-2];
        
        // Animating tips
        [self showTipsElement:info delay:2];
        [self showTipsElement:infoText delay:2];
        [self hideTipsElement:info delay:10];
        [self hideTipsElement:infoText delay:10];
    }
    return self;
}

@end
