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
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *centerLabel;
    CCSprite *centerLabelSFX;
    float originalScale; 
}
@end

@implementation Box2DUILayer

- (void)pausePressed
{
    // Проверяем не создан ли уже слой с паузой
    if ([self.parent getChildByTag:kPauseLayer]) {
        return;
    }
    // Затеняем фон
    ccColor4B c = ccc4(0, 0, 0, 100); // Black transparent background
    PauseLayer *pauseLayer = [[[PauseLayer alloc] initWithColor:c] autorelease];
    [self.parent addChild:pauseLayer z:10 tag:kPauseLayer];
    
    // Ставим на паузу всех детей основного batchnode. так просто поставить слой на паузу не достаточно
    CCLayer *gl = (CCLayer*) [self.parent getChildByTag:kBox2DLayer];
    CCSpriteBatchNode *bn = (CCSpriteBatchNode*)[gl getChildByTag:kMainSpriteBatchNode];
    [gl pauseSchedulerAndActions];
    for (CCNode *tempNode in [bn children]) {
        [tempNode pauseSchedulerAndActions];
    }
}

- (id) init {
    
    if ((self = [super init])) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
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
        
        // Init Score Label
        scoreLabel = [CCLabelBMFont labelWithString:@"                  " fntFile:@"levelNameText.fnt"];
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(padding, screenSize.height - padding);
        originalScale = 0.7;
        scoreLabel.scale = originalScale;
        [self addChild:scoreLabel];
        
        // Init Center information label for name of level and other info
        centerLabel = [CCLabelBMFont labelWithString:@"          " fntFile:@"levelNameText.fnt"];
        centerLabel.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
        centerLabel.visible = NO;
        [self addChild:centerLabel z:2];
        
        // Add Cover for center text, which would be sfx when text appear 
        centerLabelSFX = [CCSprite spriteWithSpriteFrameName:@"level_name_sfx.png"];
        centerLabelSFX.position = ccp(centerLabel.position.x - centerLabel.contentSize.width/2, centerLabel.position.y);
        centerLabelSFX.visible = NO;
        [self addChild:centerLabelSFX z:1];
    }
    return self;
}

- (void) updateScore:(int)collected need:(int)need {
    
    [scoreLabel stopAllActions];
    [scoreLabel setString:[NSString stringWithFormat:@"%i of %i collected", collected, need]];
    
    // Pop up the score
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.1 scale:originalScale * 1.1];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:originalScale];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, nil];
    [scoreLabel runAction:sequence];
}

- (BOOL)displayText:(NSString *)text
{
    [centerLabel stopAllActions];
    [centerLabel setString:text];
    centerLabel.opacity = 0;
    centerLabel.visible = YES;
    
    [centerLabelSFX stopAllActions];
    centerLabelSFX.position = ccp(centerLabel.position.x - centerLabel.contentSize.width/2, centerLabel.position.y);
    centerLabelSFX.opacity = 0;
    centerLabelSFX.visible = YES;
    
    id move = [CCMoveTo actionWithDuration:1.5 position:ccp(centerLabel.position.x + centerLabel.contentSize.width, centerLabel.position.y)];
    id fadeIn = [CCFadeIn actionWithDuration:0.4];
    id fadeInText = [CCFadeIn actionWithDuration:0.7];
    id fadeBackText = [fadeInText reverse];
    id pauseBetweenFading = [CCDelayTime actionWithDuration:0.4];
    id fadeBack = [fadeIn reverse];
    id hide = [CCHide action];
    id delayBefore = [CCDelayTime actionWithDuration:0.5];
    id delay = [CCDelayTime actionWithDuration:1.0];
    id sfxLabelFadingSeq = [CCSequence actions:fadeIn, pauseBetweenFading, fadeBack, hide, nil];
    id sfxLabelAction = [CCSpawn actions:sfxLabelFadingSeq, move, nil];
    id textAction = [CCSequence actions:delayBefore, fadeInText, delay, fadeBackText, hide, nil];
    
    [centerLabelSFX runAction:sfxLabelAction];
    [centerLabel runAction:textAction];
    return TRUE;
}

@end
