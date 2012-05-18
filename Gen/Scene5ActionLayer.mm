//
//  Scene5ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 01.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene5ActionLayer.h"
#import "MetalCell.h"

@implementation Scene5ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint screenCenter = [Helper screenCenter];
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode];
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene5bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:screenCenter];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = ccp(screenCenter.x, screenSize.height * 0.2);
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add MetalCell and pin at Center. MetalCell will rotate
        cellPos = [Helper convertPosition:ccp(480, 261)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        [self addChild:metalCell1 z:-1];
        [sceneSpriteBatchNode addChild:metalCell1.pin];
        [metalCell1 setMotorSpeed:2];
        
        // add ChildCells and joint the last with Metal Cell
        CGPoint childCellsPos[kScene5Total] = 
        {
            [Helper convertPosition:ccp(480, 200)],
            [Helper convertPosition:ccp(508, 207)],
            [Helper convertPosition:ccp(529, 225)],
            [Helper convertPosition:ccp(539, 253)],
            [Helper convertPosition:ccp(536, 283)],
            [Helper convertPosition:ccp(520, 307)],
            [Helper convertPosition:ccp(496, 318)],
            [Helper convertPosition:ccp(471, 320)],
            [Helper convertPosition:ccp(451, 313)],
            [Helper convertPosition:ccp(433, 298)],
            [Helper convertPosition:ccp(421, 275)],
            [Helper convertPosition:ccp(419, 248)],
            [Helper convertPosition:ccp(430, 225)],
            [Helper convertPosition:ccp(449, 207)]
        };
        for (int i=0; i<kScene5Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
 
        NSMutableArray *childCellsArray = [[NSMutableArray alloc] init];
        for (Box2DSprite *tempObj in [sceneSpriteBatchNode children]) {
            if ([tempObj gameObjectType] == kChildCellType) {
                [childCellsArray addObject:(ChildCell*)tempObj];
            }
        }
        // Make distance joint connections between metalCell and all ChildCells
        b2DistanceJointDef disJointDef;
        disJointDef.length = exitCell.contentSize.width * 1.17 / PTM_RATIO;
        disJointDef.bodyA = metalCell1.body;
        disJointDef.localAnchorB.SetZero();
        for (int i=0; i < childCellsArray.count; i++) {
            ChildCell *tempCell = (ChildCell*)[childCellsArray objectAtIndex:i];
            disJointDef.bodyB = tempCell.body;
            disJointDef.localAnchorA = metalCell1.body->GetLocalPoint(tempCell.body->GetPosition());
            world->CreateJoint(&disJointDef);
        }
        [childCellsArray release];
        childCellsArray = nil;
    }
    return self;
}

@end
