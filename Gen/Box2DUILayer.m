//
//  Box2DUILayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DUILayer.h"
#import "CCMenuItemSpriteIndependent.h"
#import "GameManager.h"

@interface Box2DUILayer()
{
    CCLabelTTF *scoreLabel;
}

@end

@implementation Box2DUILayer

- (void)pausePressed
{
    GameManager *gameManager = [GameManager sharedGameManager];
    [gameManager runSceneWithID:gameManager.curLevel];
}

- (id) init {
    
    if ((self = [super init])) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:22];
        scoreLabel.color = ccc3(0, 0, 0);
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(0, screenSize.height);
        [self addChild:scoreLabel];
        
        // Place pause menu button
        CCSprite *pauseGameSprite = [CCSprite spriteWithSpriteFrameName:@"button_pause.png"];
        float padding = [pauseGameSprite contentSize].width*0.5 * 0.2; // отступ от края экрана c учетом спец эффекта меню
        [pauseGameSprite setAnchorPoint:ccp(1, 1)];
        [pauseGameSprite setPosition:ccp(screenSize.width-padding, screenSize.height-padding)];
        [pauseGameSprite setOpacity:200];
        [pauseGameSprite setScale:0.8];
        [self addChild:pauseGameSprite];
        CCMenuItemSpriteIndependent *pauseGameButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:pauseGameSprite selectedSprite:nil target:self selector:@selector(pausePressed)];
        CCMenu *pauseMenu = [CCMenu menuWithItems:pauseGameButton, nil];
        [self addChild:pauseMenu z:5];
    }
    return self;
}

- (void) updateScore:(int)collected need:(int)need {
    
    [scoreLabel stopAllActions];
    [scoreLabel setString:[NSString stringWithFormat:@"%i of %i collected", collected, need]];
    
    // Pop up the score
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.2 scale:1.2];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:1.0];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, nil];
    [scoreLabel runAction:sequence];
}

@end
