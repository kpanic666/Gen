//
//  Scene3ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 30.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene3ActionLayer.h"

@implementation Scene3ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint screenCenter = [Helper screenCenter];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:screenCenter];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Add Tutorial text and arrows
        CCSprite *info = [CCSprite spriteWithSpriteFrameName:@"tut_warning.png"];
        info.position = [Helper convertPosition:ccp(844, 116)];
        info.opacity = 0;
        [sceneSpriteBatchNode addChild:info z:-2];
        CCLabelTTF *infoText = [CCLabelTTF labelWithString:@"Keep the\n food away\n from garbage" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        infoText.color = ccBLACK;
        infoText.opacity = 0;
        infoText.position = ccp(info.position.x, info.position.y - info.contentSize.height * 0.7 - infoText.contentSize.height * 0.5);
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
