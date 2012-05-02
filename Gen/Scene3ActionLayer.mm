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
        CGPoint cellPos;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode];
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene3bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(32, 605)];
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell1"];
        [self addChild:groundCell1 z:-1];
        
        // add ChildCells
        float offsetX = 5;
        float offsetY = 30;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offsetX *= 2;
            offsetY *= 2;
        }
        for (int i = 0; i < 7; i++) {
            [self createChildCellAtLocation:ccp(screenSize.width*0.1 + i * offsetX, screenSize.height*0.3 + i * offsetY)];
        }
        NSMutableArray *childCellsArray = [[NSMutableArray alloc] init];
        for (Box2DSprite *tempObj in [sceneSpriteBatchNode children]) {
            if ([tempObj gameObjectType] == kChildCellType) {
                [childCellsArray addObject:(ChildCell*)tempObj];
            }
        }
        
        b2DistanceJointDef disJointDef;
        disJointDef.localAnchorA.SetZero();
        disJointDef.localAnchorB.SetZero();
        for (int i=0; i < childCellsArray.count; i++) {
            ChildCell *tempCell = (ChildCell*)[childCellsArray objectAtIndex:i];
            if (i == 0) {
                disJointDef.length = offsetY*2.5 / PTM_RATIO;
                disJointDef.bodyA = groundCell1.body;
                disJointDef.bodyB = tempCell.body;
                world->CreateJoint(&disJointDef);
            }
            else {
                disJointDef.length = offsetY / PTM_RATIO;
                ChildCell *prevCell = (ChildCell*)[childCellsArray objectAtIndex:i-1];
                disJointDef.bodyA = prevCell.body;
                disJointDef.bodyB = tempCell.body;
                world->CreateJoint(&disJointDef);
            }
        }
        [childCellsArray release];
        childCellsArray = nil;
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(142, 629)];
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(677, 369)];
        RedCell *redCell2 = [RedCell redCellInWorld:world position:cellPos name:@"redCell2"];
        [self addChild:redCell2 z:-1];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(488, 182)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
    }
    return self;
}

@end
