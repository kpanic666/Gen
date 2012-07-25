//
//  Scene1ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene1ActionLayer.h"

@implementation Scene1ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint screenCenter = [Helper screenCenter];
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene1bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:screenCenter];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:ccp(screenSize.width*0.9, screenSize.height*0.15)] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add ChildCells
        for (int i = 0; i < kScene1Total-1; i++) {
            [self createChildCellAtLocation:ccp(screenCenter.x + i * 5, screenCenter.y + i * 5)];
        }
        
        // add BombCell
        [self createBombCellAtLocation:ccp(screenCenter.x + kScene1Total * 5, screenCenter.y + kScene1Total * 5)];
        
        // add GroundCells
        [self createGroundCellInWorld:world position:ccp(screenSize.width*0.65, screenSize.height*0.08) name:@"groundCell1"];
        [self createGroundCellInWorld:world position:ccp(screenSize.width*0.25, screenSize.height*0.7) name:@"groundCell2"];
        
        // add RedCells
        [self createRedCellInWorld:world position:ccp(screenSize.width*0.87, screenSize.height*0.45) name:@"redCell1"];
        
        // Add Tutorial text and arrows
        float fontSize = [Helper convertFontSize:14];
        NSString *fontName = @"Verdana";
        // ----Exit Tip----
        CCSprite *toExitArrow = [CCSprite spriteWithFile:@"tut_arrow2.png"];
        toExitArrow.flipY = YES;
        toExitArrow.rotation = 30;
        toExitArrow.opacity = 0;
        toExitArrow.position = ccp(screenSize.width*0.79, screenSize.height*0.26);
        [self addChild:toExitArrow z:-2];
        CCLabelTTF *toExitText = [CCLabelTTF labelWithString:@"To this" fontName:fontName fontSize:fontSize];
        toExitText.position = ccp(screenSize.width*0.68, screenSize.height*0.31);
        toExitText.color = ccBLACK;
        toExitText.opacity = 0;
        [self addChild:toExitText z:-2];
        // ----CHild cells tip----
        CCSprite *toChildArrow = [CCSprite spriteWithFile:@"tut_arrow1.png"];
        toChildArrow.rotation = 90;
        toChildArrow.opacity = 0;
        toChildArrow.position = ccp(screenSize.width*0.55, screenSize.height*0.72);
        [self addChild:toChildArrow z:-2];
        CCLabelTTF *toChildText = [CCLabelTTF labelWithString:@"Get this" fontName:fontName fontSize:fontSize];
        toChildText.position = ccp(screenSize.width*0.55, screenSize.height*0.82);
        toChildText.color = ccBLACK;
        toChildText.opacity = 0;
        [self addChild:toChildText z:-2];
        // ----RedCell tip----
        CCSprite *toRedCellArrow = [CCSprite spriteWithTexture:[toExitArrow texture]];
        toRedCellArrow.rotation = 90;
        toRedCellArrow.opacity = 0;
        toRedCellArrow.position = ccp(screenSize.width*0.87, screenSize.height*0.62);
        [self addChild:toRedCellArrow z:-2];
        CCLabelTTF *toRedCellText = [CCLabelTTF labelWithString:@"Avoid this" fontName:fontName fontSize:fontSize];
        toRedCellText.color = ccBLACK;
        toRedCellText.opacity = 0;
        toRedCellText.position = ccp(screenSize.width*0.87, screenSize.height*0.75);
        [self addChild:toRedCellText z:-2];
        // ----How to move Tip----
        CCSprite *howToMoveFinger = [CCSprite spriteWithFile:@"tut_fingerprint.png"];
        howToMoveFinger.position = ccp(screenSize.width*0.25, screenSize.height*0.4);
        howToMoveFinger.opacity = 0;
        [self addChild:howToMoveFinger z:-2];
        CCLabelTTF *howToMoveText = [CCLabelTTF labelWithString:@"Touch to pull the cells" fontName:fontName fontSize:fontSize];
        howToMoveText.color = ccBLACK;
        howToMoveText.opacity = 0;
        howToMoveText.position = ccp(screenSize.width*0.25, screenSize.height*0.28);
        [self addChild:howToMoveText z:-2];
        
        // Fading out tips
        float delay = 3;
        [self showTipsElement:toChildArrow delay:delay];
        [self showTipsElement:toChildText delay:delay++];
        [self showTipsElement:toExitArrow delay:delay];
        [self showTipsElement:toExitText delay:delay++];
        [self showTipsElement:toRedCellArrow delay:delay];
        [self showTipsElement:toRedCellText delay:delay++];
        [self showTipsElement:howToMoveFinger delay:delay];
        [self showTipsElement:howToMoveText delay:delay];
    }
    return self;
}

@end
