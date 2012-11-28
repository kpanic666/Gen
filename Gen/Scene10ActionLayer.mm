//
//  Scene10ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 14.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene10ActionLayer.h"

@implementation Scene10ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];

        // Add Tutorial text and arrows
        CCSprite *info = [CCSprite spriteWithSpriteFrameName:@"tut_warning.png"];
        info.position = [Helper convertPosition:ccp(230, 110)];
        info.opacity = 0;
        [sceneSpriteBatchNode addChild:info z:-2];
        CCLabelTTF *infoText = [CCLabelTTF labelWithString:@"Some food can explode!\n Try feed it to Genby\n or get rid of it" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
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
