//
//  Scene6ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 10.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene6ActionLayer.h"

@implementation Scene6ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene6bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(80, 80)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(813, 179)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        cellPos = [Helper convertPosition:ccp(893, 595)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell2"];
        cellPos = [Helper convertPosition:ccp(263, 397)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell3"];
        cellPos = [Helper convertPosition:ccp(561, 430)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell4"];
        
        // add ChildCells
        CGPoint childCellsPos[kScene6Total-1] =
        {
            [Helper convertPosition:ccp(116, 192)],
            [Helper convertPosition:ccp(190, 206)],
            [Helper convertPosition:ccp(232, 245)],
            [Helper convertPosition:ccp(296, 231)],
            [Helper convertPosition:ccp(372, 217)],
            [Helper convertPosition:ccp(430, 245)],
            [Helper convertPosition:ccp(440, 305)],
            [Helper convertPosition:ccp(486, 351)],
            [Helper convertPosition:ccp(430, 401)],
            [Helper convertPosition:ccp(416, 488)],
            [Helper convertPosition:ccp(372, 546)],
            [Helper convertPosition:ccp(318, 585)],
            [Helper convertPosition:ccp(223, 609)],
            [Helper convertPosition:ccp(130, 590)],
            [Helper convertPosition:ccp(65, 542)],
            [Helper convertPosition:ccp(42, 474)],
            [Helper convertPosition:ccp(37, 397)],
            [Helper convertPosition:ccp(76, 323)],
            [Helper convertPosition:ccp(70, 245)],
            [Helper convertPosition:ccp(566, 351)],
            [Helper convertPosition:ccp(637, 411)],
            [Helper convertPosition:ccp(630, 474)],
            [Helper convertPosition:ccp(586, 510)],
            [Helper convertPosition:ccp(526, 500)],
            [Helper convertPosition:ccp(486, 460)],
            [Helper convertPosition:ccp(500, 390)],
            [Helper convertPosition:ccp(771, 599)],
            [Helper convertPosition:ccp(785, 538)],
            [Helper convertPosition:ccp(830, 488)],
            [Helper convertPosition:ccp(907, 474)],
            [Helper convertPosition:ccp(689, 27)],
            [Helper convertPosition:ccp(667, 90)],
            [Helper convertPosition:ccp(681, 161)],
            [Helper convertPosition:ccp(651, 220)],
            [Helper convertPosition:ccp(644, 292)],
            [Helper convertPosition:ccp(681, 358)],
            [Helper convertPosition:ccp(780, 376)],
            [Helper convertPosition:ccp(852, 333)],
            [Helper convertPosition:ccp(921, 265)],
            [Helper convertPosition:ccp(631, 220)]
        };
        for (int i=0; i<kScene6Total-1; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        
        // add BombCell
        [self createBombCellAtLocation:ccp([Helper screenCenter].x + kScene6Total * 5, [Helper screenCenter].y + kScene6Total * 5)];
    }
    return self;
}


@end
