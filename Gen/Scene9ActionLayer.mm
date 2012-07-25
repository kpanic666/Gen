//
//  Scene9ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 11.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene9ActionLayer.h"
#import "MetalCell.h"

@implementation Scene9ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene9bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(405, 555)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(587, 313)];
        CGPoint pinPos = [Helper convertPosition:ccp(480, 310)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:pinPos];
        [self addChild:metalCell1 z:-1];
        [sceneSpriteBatchNode addChild:metalCell1.pin];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(94, 92)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        
        // add ChildCells
        CGPoint childCellsPos[kScene9Total] = 
        {
            [Helper convertPosition:ccp(740, 226)],
            [Helper convertPosition:ccp(795, 266)],
            [Helper convertPosition:ccp(795, 361)],
            [Helper convertPosition:ccp(740, 394)]
        };
        for (int i=0; i<kScene9Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        NSMutableArray *childCellsArray = [[NSMutableArray alloc] init];
        for (CCSprite *tempSprite in [sceneSpriteBatchNode children]) {
            if ([tempSprite isKindOfClass:[Box2DSprite class]])
            {
                Box2DSprite *tempObj = (Box2DSprite*)tempSprite;
                if ([tempObj gameObjectType] == kChildCellType) {
                    [childCellsArray addObject:(ChildCell*)tempObj];
                }
            }
        }
        // Make distance joint connections between metalCell and all ChildCells
        b2DistanceJointDef disJointDef;
        disJointDef.length = exitCell.contentSize.width * 0.9 / PTM_RATIO;
        disJointDef.bodyA = metalCell1.body;
        disJointDef.localAnchorB.SetZero();
        disJointDef.collideConnected = true;
        // Calculate offset for disJoint to connect to left side of metal cell (at center of the circle)
        float offset = (metalCell1.contentSize.width * 0.5 - metalCell1.contentSize.width / 16) / PTM_RATIO;
        for (int i=0; i < childCellsArray.count; i++) {
            ChildCell *tempCell = (ChildCell*)[childCellsArray objectAtIndex:i];
            disJointDef.bodyB = tempCell.body;
            disJointDef.localAnchorA = b2Vec2(offset, 0);
            world->CreateJoint(&disJointDef);
        }
        [childCellsArray release];
        childCellsArray = nil;
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(723, 550)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell1"];
        cellPos = [Helper convertPosition:ccp(118, 550)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell2"];
        cellPos = [Helper convertPosition:ccp(328, 491)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell3"];
        cellPos = [Helper convertPosition:ccp(487, -26)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell4"];
        cellPos = [Helper convertPosition:ccp(68, 74)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell5"];
        cellPos = [Helper convertPosition:ccp(112, 74)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell6"];
    }
    return self;
}

@end
