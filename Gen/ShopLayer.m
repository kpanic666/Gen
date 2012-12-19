//
//  ShopLayer.m
//  Gen
//
//  Created by Andrey Korikov on 17.12.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ShopLayer.h"

@interface ShopLayer()
{
    CCSpriteBatchNode *shopBatchNode;
    CCMenu *shopMenu;
    CGSize screenSize;
}

@end

@implementation ShopLayer

- (id)initWithColor:(ccColor4B)color
{
    if ((self = [super initWithColor:color]))
    {
        screenSize = [CCDirector sharedDirector].winSize;
        
        shopBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"superpower_popup.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"superpower_popup.plist"];
        [self addChild:shopBatchNode];
        
        // Создаем подложку для всплывающего окна магазина
        [self createUndercoverWithHeight:screenSize.height*0.8];
//        [shopBatchNode runAction:[CCScaleTo actionWithDuration:0.3 scaleX:1 scaleY:1]];
        
    }
    return self;
}

- (void)createUndercoverWithHeight:(float)uHeight
{
    CCSprite *bottomSprite = [CCSprite spriteWithSpriteFrameName:@"bottom_border.png"];
    CCSprite *topSprite = [CCSprite spriteWithSpriteFrameName:@"top_border.png"];
    CCSprite *middleSprite = [CCSprite spriteWithSpriteFrameName:@"middle.png"];

    uHeight = floorf(uHeight);
    int numOfMiddleTiles = (uHeight - topSprite.contentSize.height - bottomSprite.contentSize.height) / middleSprite.contentSize.height + 2;

    // ADD средние планки
    // Определяем начальную верхнюю позицию
    CGPoint plankPos = ccp(screenSize.width * 0.5, floorf(screenSize.height*0.5 + uHeight * 0.5));
    float yOffset = 0;
    for (int x = 0; x < numOfMiddleTiles; x++)
    {
        plankPos = ccpSub(plankPos, ccp(0, yOffset));

        if (x == 0)
        {
            // ADD верхюю планку
            [topSprite setAnchorPoint:ccp(0.5, 1)];
            [topSprite setPosition:plankPos];
            [shopBatchNode addChild:topSprite z:1];
            yOffset = topSprite.contentSize.height;
        }
        else if (x == numOfMiddleTiles-1)
        {
            // ADD нижнюю планку
            [bottomSprite setAnchorPoint:ccp(0.5, 1)];
            [bottomSprite setPosition:plankPos];
            [shopBatchNode addChild:bottomSprite z:1];
        }
        else
        {
            CCSprite *midSprite = [CCSprite spriteWithSpriteFrameName:@"middle.png"];
            [midSprite setAnchorPoint:ccp(0.5, 1)];
            //        [midSprite setScaleX:0];
            [midSprite setPosition:plankPos];
            [shopBatchNode addChild:midSprite z:0];
            yOffset = middleSprite.contentSize.height;
        }
    }
}

@end
