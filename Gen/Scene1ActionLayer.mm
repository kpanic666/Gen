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
        for (int i = 0; i < kScene1Total; i++) {
            [self createChildCellAtLocation:ccp(screenCenter.x + i * 5, screenCenter.y + i * 5)];
        }
        
        // add GroundCells
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:ccp(screenSize.width*0.65, screenSize.height*0.08) name:@"groundCell1"];
        GroundCell *groundCell2 = [GroundCell groundCellInWorld:world position:ccp(screenSize.width*0.25, screenSize.height*0.7) name:@"groundCell2"];
        [self addChild:groundCell1 z:-1];
        [self addChild:groundCell2 z:-1];
        
        // add RedCells
        RedCell *redCell1 = [RedCell redCellInWorld:world position:ccp(screenSize.width*0.87, screenSize.height*0.45) name:@"redCell1"];
        [self addChild:redCell1 z:-1];
    }
    return self;
}

@end
