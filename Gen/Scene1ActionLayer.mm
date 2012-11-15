//
//  Scene1ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene1ActionLayer.h"

@implementation Scene1ActionLayer
{
    CCLabelTTF *howToMoveText;
    CCSprite *howToMoveFinger;
    CCSprite *toExitArrow;
    CCLabelTTF *toExitText;
    int tutStep;
}

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
        tutStep = 0;
        float fontSize = [Helper convertFontSize:12];
        NSString *fontName = @"Verdana";
        // ----Exit Tip----
        toExitArrow = [CCSprite spriteWithSpriteFrameName:@"tut_arrow2.png"];
        toExitArrow.flipY = YES;
        toExitArrow.rotation = 30;
        toExitArrow.opacity = 0;
        toExitArrow.position = ccp(screenSize.width*0.79, screenSize.height*0.35);
        [sceneSpriteBatchNode addChild:toExitArrow z:0];
        CGSize toExitTextSize = CGSizeMake(100, 50);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            toExitTextSize = CGSizeMake(toExitTextSize.width * 2, toExitTextSize.height * 2);
        }
        toExitText = [CCLabelTTF labelWithString:@"Deliver food to Genby" dimensions:toExitTextSize hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap fontName:fontName fontSize:fontSize];
        toExitText.position = ccp(screenSize.width*0.68, screenSize.height*0.4);
        toExitText.color = ccBLACK;
        toExitText.opacity = 0;
        [self addChild:toExitText z:1];
        // ----How to move Tip----
        howToMoveFinger = [CCSprite spriteWithSpriteFrameName:@"tut_finger_tap.png"];
        howToMoveFinger.position = [Helper convertPosition:ccp(384, 141)];
        howToMoveFinger.opacity = 0;
        [sceneSpriteBatchNode addChild:howToMoveFinger z:-2];
        [howToMoveFinger runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                     [CCScaleTo actionWithDuration:0.5 scale:0.9],
                                                                     [CCScaleTo actionWithDuration:0.5 scale:1], nil]]];
        howToMoveText = [CCLabelTTF labelWithString:@"Touch and hold to pull the food" dimensions:toExitTextSize hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap fontName:fontName fontSize:fontSize];
        howToMoveText.color = ccBLACK;
        howToMoveText.opacity = 0;
        howToMoveText.position = ccp(howToMoveFinger.position.x + howToMoveFinger.contentSize.width * 1.5, howToMoveFinger.position.y);
        [self addChild:howToMoveText z:-2];
        
        // Animating tips
        float delay = 3;
        [self showTipsElement:howToMoveFinger delay:delay];
        [self showTipsElement:howToMoveText delay:delay];
    }
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    switch (tutStep) {
        case 0:
        {
            if ([howToMoveText numberOfRunningActions] != 0) {
                break;
            }
            else
            {
                tutStep = 1;
            }
        }
        case 1:
        {
            tutStep = 2;
            [howToMoveFinger stopAllActions];
            id moveForwardAction = [CCMoveTo actionWithDuration:2 position:[Helper convertPosition:ccp(866, 356)]];
            id moveReverseAction = [CCMoveTo actionWithDuration:0 position:howToMoveFinger.position];
            [howToMoveFinger runAction:[CCSequence actions:
                                        [CCRepeat actionWithAction:
                                         [CCSequence actionOne:moveForwardAction two:moveReverseAction] times:2],
                                        moveForwardAction,
                                        nil]];
            howToMoveText.opacity = 0;
            howToMoveText.position = ccp(screenSize.width *0.85, screenSize.height *0.7);
            [howToMoveText setString:@"Slide your finger to move the food"];
            [self showTipsElement:howToMoveText delay:0];
            [self showTipsElement:toExitArrow delay:0];
            [self showTipsElement:toExitText delay:0];
            [self hideTipsElement:howToMoveFinger delay:9];
            [self hideTipsElement:howToMoveText delay:9];
            [self hideTipsElement:toExitArrow delay:9];
            [self hideTipsElement:toExitText delay:9];
            
            break;
        }
            
        default:
            break;
    }
    
    
    [super ccTouchBegan:touch withEvent:event];
    return TRUE;
}

@end
