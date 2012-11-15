//
//  Scene2ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 29.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene2ActionLayer.h"

@implementation Scene2ActionLayer

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
        
        // Add moving walls
        cellPos = [Helper convertPosition:ccp(450, 222)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:0 posOffset:5.0f speed:4];
        cellPos = [Helper convertPosition:ccp(594, 562)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:-5.0f posOffset:0 speed:4];
        cellPos = [Helper convertPosition:ccp(732, 222)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:0 posOffset:5.0f speed:4];
        
        // Add Tutorial text and arrows
        CGSize toExitTextSize = CGSizeMake(100, 30);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            toExitTextSize = CGSizeMake(toExitTextSize.width * 2, toExitTextSize.height * 2);
        }

        // ----Tip----
        CCSprite *info = [CCSprite spriteWithSpriteFrameName:@"tut_lightbulb.png"];
        info.position = [Helper convertPosition:ccp(527, 47)];
        info.opacity = 0;
        [sceneSpriteBatchNode addChild:info z:-2];
        CCLabelTTF *infoText = [CCLabelTTF labelWithString:@"Collect as many food as you can" dimensions:toExitTextSize hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap fontName:@"Verdana" fontSize:[Helper convertFontSize:12] ];
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
