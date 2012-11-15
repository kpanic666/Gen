//
//  Scene9ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 11.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene9ActionLayer.h"

@implementation Scene9ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        CGPoint screenCenter = [Helper screenCenter];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:screenCenter];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add MetalCell and pin at Center. MetalCell will rotate
        cellPos = [Helper convertPosition:ccp(480, 261)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        [self addChild:metalCell1 z:0];
        [sceneSpriteBatchNode addChild:metalCell1.pin];
        [metalCell1 setMotorSpeed:2];
        
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
        disJointDef.length = metalCell1.contentSize.width / PTM_RATIO;
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
        
        // ----Tip----
        CCSprite *info = [CCSprite spriteWithSpriteFrameName:@"tut_lightbulb.png"];
        info.position = [Helper convertPosition:ccp(300, 80)];
        info.opacity = 0;
        [sceneSpriteBatchNode addChild:info z:-2];
        CCLabelTTF *infoText = [CCLabelTTF labelWithString:@"Sometimes you just need to wait" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        infoText.color = ccBLACK;
        infoText.opacity = 0;
        infoText.position = ccp(info.position.x + info.contentSize.width*0.7 + infoText.contentSize.width*0.5, info.position.y);
        [self addChild:infoText z:-2];
        
        // Animating tips
        [self showTipsElement:info delay:2];
        [self showTipsElement:infoText delay:2];
        [self hideTipsElement:info delay:10];
        [self hideTipsElement:infoText delay:10];
    }
    return self;
}

@end
