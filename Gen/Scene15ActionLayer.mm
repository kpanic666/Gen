//
//  Scene15ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 17.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene15ActionLayer.h"

@implementation Scene15ActionLayer
{
    CCSprite *info;
    CCLabelTTF *infoText;
    CCSprite *toExitArrow;
    CCLabelTTF *toExitText;
    int tutStep;
    BubbleCell *bubble1;
    BubbleCell *bubble2;
}

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

        // add Bubble Cells
        cellPos = [Helper convertPosition:ccp(79, 420)];
        bubble1 = [self createBubbleCellAtLocation:cellPos];
        cellPos = [Helper convertPosition:ccp(312, 339)];
        bubble2 = [self createBubbleCellAtLocation:cellPos];
        
        // Add Tutorial text and arrows
        tutStep = 0;
        // -----About Bubble Tip-----
        info = [CCSprite spriteWithSpriteFrameName:@"tut_arrow1.png"];
        info.position = [Helper convertPosition:ccp(78, 351)];
        info.opacity = 0;
        info.rotation = 90;
        [sceneSpriteBatchNode addChild:info z:-2];
        infoText = [CCLabelTTF labelWithString:@"The bubble\n will lift the\n food up" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        infoText.color = ccBLACK;
        infoText.opacity = 0;
        infoText.position = ccp(info.position.x, info.position.y + info.contentSize.width*0.6 + infoText.contentSize.height * 0.5);
        [self addChild:infoText z:-2];
        // -----Tap the bubble Tip-----
        toExitArrow = [CCSprite spriteWithSpriteFrameName:@"tut_lightbulb.png"];
        toExitArrow.opacity = 0;
        toExitArrow.position = [Helper convertPosition:ccp(78, 211)];
        [sceneSpriteBatchNode addChild:toExitArrow z:-2];
        toExitText = [CCLabelTTF labelWithString:@"Pop the\n bubble with\n your finger" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        toExitText.position = ccp(toExitArrow.position.x, toExitArrow.position.y - toExitArrow.contentSize.height*0.5 - toExitText.contentSize.height * 0.5);
        toExitText.color = ccBLACK;
        toExitText.opacity = 0;
        [self addChild:toExitText z:-2];
                
        // Animating tips
        [self showTipsElement:info delay:1];
        [self showTipsElement:infoText delay:1];
        
        // Scheduling Tut updater check. If 1st bubble will be activated, then hide 1st tip, and display 2nd.
        [self schedule:@selector(tutsChecker) interval:0.5];
    }
    return self;
}

- (void)tutsChecker
{
    switch (tutStep) {
        case 0:
        {
            if (bubble1.wasUsed) {
                tutStep = 1;
                // Моментально скрыть первый совет, показать след и скрыть его через 5 сек
                [self hideTipsElement:info delay:0];
                [self hideTipsElement:infoText delay:0];
                [self showTipsElement:toExitArrow delay:1];
                [self showTipsElement:toExitText delay:1];
                [self hideTipsElement:toExitArrow delay:6];
                [self hideTipsElement:toExitText delay:6];
            }
            break;
        }
        case 1:
        {
            if (bubble2.wasUsed) {
                tutStep = 2;
                CCSprite *tutSprite2 = [CCSprite spriteWithSpriteFrameName:@"tut_lightbulb.png"];
                tutSprite2.opacity = 0;
                tutSprite2.position = [Helper convertPosition:ccp(354, 150)];
                [sceneSpriteBatchNode addChild:tutSprite2 z:-2];
                CCLabelTTF *tutText2 = [CCLabelTTF labelWithString:@"Don't let\n the food\n leave the stage" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
                tutText2.position = ccp(tutSprite2.position.x, tutSprite2.position.y - tutSprite2.contentSize.height*0.5 - tutText2.contentSize.height * 0.5);
                tutText2.color = ccBLACK;
                tutText2.opacity = 0;
                [self addChild:tutText2 z:-2];
                
                // Animating tips
                [self showTipsElement:tutSprite2 delay:0];
                [self showTipsElement:tutText2 delay:0];
                [self hideTipsElement:tutSprite2 delay:4];
                [self hideTipsElement:tutText2 delay:4];
            }
            break;
        }
        case 2:
            [self unschedule:@selector(_cmd)];
            break;
            
        default:
            break;
    }
}

@end
