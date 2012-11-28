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
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(32, 605)];
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell1"];
        [self addChild:groundCell1 z:0];
        
        // add ChildCells
        float offsetY = 30;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offsetY *= 2;
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
        
        // Add Tutorial text and arrows
        float fontSize = [Helper convertFontSize:12];
        NSString *fontName = @"Verdana";
        NSString *myText = @"Collect necessary\n amount of food";
        CGSize maxSize = CGSizeMake(screenSize.width/3, 400);
        // ----Score Tip----
        CCSprite *toScoreArrow = [CCSprite spriteWithSpriteFrameName:@"tut_arrow2.png"];
        toScoreArrow.rotation = 230;
        toScoreArrow.opacity = 0;
        toScoreArrow.position = ccp(screenSize.width*0.19, screenSize.height*0.84);
        [sceneSpriteBatchNode addChild:toScoreArrow z:-2];
        CGSize actualSize = [myText sizeWithFont:[UIFont fontWithName:fontName size:fontSize]
                               constrainedToSize:maxSize
                                   lineBreakMode:UILineBreakModeWordWrap];
        CCLabelTTF *toScoreText = [CCLabelTTF labelWithString:myText dimensions:actualSize hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap fontName:fontName fontSize:fontSize];
        toScoreText.position = ccp(screenSize.width*0.25, screenSize.height*0.7);
        toScoreText.color = ccBLACK;
        toScoreText.opacity = 0;
        [self addChild:toScoreText z:-2];
        
        // Fading out tips
        [self showTipsElement:toScoreArrow delay:2];
        [self showTipsElement:toScoreText delay:2];
        [self hideTipsElement:toScoreArrow delay:8];
        [self hideTipsElement:toScoreText delay:8];
    }
    return self;
}


@end
