//
//  Scene2ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 29.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene2ActionLayer.h"
#import "MetalCell.h"

@implementation Scene2ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode];
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene2bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ChildCells
        for (int i = 0; i < kScene2Needed; i++) {
            [self createChildCellAtLocation:ccp(screenSize.width*0.1 + i * 5, screenSize.height*0.3 + i * 5)];
        }
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(445, 541)];
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(445, 167)];
        RedCell *redCell2 = [RedCell redCellInWorld:world position:cellPos name:@"redCell2"];
        [self addChild:redCell2 z:-1];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(834, 354)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(442, 352)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        [self addChild:metalCell1 z:-1];
        [sceneSpriteBatchNode addChild:metalCell1.pin];
    }
    return self;
}

@end
