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
#import "PauseLayer.h"
#import "Helper.h"

@interface Box2DUILayer()
{
    CCLabelTTF *scoreLabel;
    CCLabelTTF *centerLabel;
}
@end

@implementation Box2DUILayer

- (void)pausePressed
{
    ccColor4B c = ccc4(0, 0, 0, 100); // Black transparent background
    PauseLayer *pauseLayer = [[[PauseLayer alloc] initWithColor:c] autorelease];
    [self.parent addChild:pauseLayer z:10 tag:kPauseLayer];
    CCLayer *gl = (CCLayer*) [self.parent getChildByTag:kBox2DLayer];
    CCSpriteBatchNode *bn = (CCSpriteBatchNode*)[gl getChildByTag:kMainSpriteBatchNode];
    [gl pauseSchedulerAndActions];
    // Ставим на паузу всех детей основного batchnode. так просто поставить слой на паузу не достаточно
    for (CCNode *tempNode in [bn children]) {
        [tempNode pauseSchedulerAndActions];
    }
}

- (id) init {
    
    if ((self = [super init])) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // Init Needed Count Label
        scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"Zapfino" fontSize:[Helper convertFontSize:14]];
        scoreLabel.color = ccc3(0, 0, 0);
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(0, screenSize.height);
        [self addChild:scoreLabel];
        
        // Init Center information label for name of level and other info
        centerLabel = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:[Helper convertFontSize:30]];
        centerLabel.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
        centerLabel.color = ccc3(255, 255, 0);
        centerLabel.visible = NO;
        [self addChild:centerLabel];
        
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
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.1 scale:1.1];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:1.0];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, nil];
    [scoreLabel runAction:sequence];
}

- (BOOL)displayText:(NSString *)text
{
    [centerLabel stopAllActions];
    [centerLabel setString:text];
    centerLabel.visible = YES;
    centerLabel.opacity = 255;
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.5 scale:1.2];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:1.0];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.0];
    CCFadeOut *fade = [CCFadeOut actionWithDuration:0.5];
    CCHide *hide = [CCHide action];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, delay, fade, hide, nil];
    [centerLabel runAction:sequence];
    return TRUE;
}

@end
