//
//  Scene16ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 17.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene16ActionLayer.h"

@implementation Scene16ActionLayer

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
        
        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(587, 313)];
        CGPoint pinPos = [Helper convertPosition:ccp(480, 310)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:pinPos];
        [self addChild:metalCell1 z:0];
        [sceneSpriteBatchNode addChild:metalCell1.pin];

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
        disJointDef.length = exitCell.contentSize.width * 0.8 / PTM_RATIO;
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
    }
    return self;
}

@end
