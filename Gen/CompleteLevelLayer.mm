//
//  CompleteLevelLayer.m
//  Gen
//
//  Created by Andrey Korikov on 21.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "CompleteLevelLayer.h"
#import "GameManager.h"
#import "CCMenuItemSpriteIndependent.h"
#import "Helper.h"

#define kBackgroundTag 12
#define kStar1Tag 1
#define kStar2Tag 2
#define kStar3Tag 3

@interface CompleteLevelLayer()
{
    CCParticleSystemQuad *starEmitter;
}
- (void)displayGameOverMenuButtons;
- (void)rollBorderFrame;
- (CCTexture2D*)genBorderWithSize:(CGSize)textureSize;
- (void)popUpStars;
- (float)showMenuNodes;
@end

@implementation CompleteLevelLayer

- (void)rollBorderFrame
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGSize borderSize = CGSizeMake(screenSize.width, screenSize.height * 0.15);
    
    CCTexture2D *borderTex = [self genBorderWithSize:borderSize];
    CCSprite *borderTop = [CCSprite spriteWithTexture:borderTex];
    CCSprite *borderBottom = [CCSprite spriteWithTexture:borderTex];
    borderTop.anchorPoint = ccp(0.5, 0);
    borderTop.position = ccp(screenSize.width * 0.5, screenSize.height);
    borderBottom.anchorPoint = ccp(0.5, 1);
    borderBottom.position = ccp(screenSize.width * 0.5, 0);
    [self addChild:borderTop];
    [self addChild:borderBottom];
    
    // Actions
    id callAction = [CCCallFunc actionWithTarget:self selector:@selector(displayGameOverMenuButtons)];
    CGPoint borderPos = ccp(screenSize.width * 0.5, screenSize.height - [borderTop contentSize].height);
    [borderTop runAction:[CCMoveTo actionWithDuration:0.5 position:borderPos]];
    borderPos = ccp(screenSize.width * 0.5, [borderBottom contentSize].height);
    [borderBottom runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.5 position:borderPos], callAction, nil]];
}

- (CCTexture2D*)genBorderWithSize:(CGSize)textureSize {
    
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height pixelFormat:kCCTexture2DPixelFormat_RGB565];
    [rt beginWithClear:0 g:0 b:0 a:1];
    [rt end];
    return rt.sprite.texture;
}

- (id)initWithColor:(ccColor4B)color
{
    if ((self = [super initWithColor:color]))
    {
        // Опускаем черный рамки сверху и снизу. Как только они на месте - постепенно осветляем фон
        [self rollBorderFrame];
    }
    
    return self;
}

- (void)levelSelectPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [[GameManager sharedGameManager] runSceneWithID:kLevelSelectScene];
}

- (void)resetPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [[GameManager sharedGameManager] reloadCurrentScene];
}

- (void)nextPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [[GameManager sharedGameManager] runNextScene];
}

- (void)displayGameOverMenuButtons
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float padding, xButtonPos, yButtonPos;
    
    // Fade Out self layer color to 50% transperency
    [self runAction:[CCFadeTo actionWithDuration:0.3 opacity:128]];
    
    // Menu undercover
    CCSprite *undercover = [CCSprite spriteWithFile:@"completeMenuUnder.png"];
    undercover.position = ccp(screenSize.width * 0.5, screenSize.height * 0.5);
    [self addChild:undercover z:0 tag:kBackgroundTag];
    CGSize undercoverSize = undercover.contentSize;
    
    // Create Label for game status (Win or Lose)
    CCLabelTTF *levelCompleteLabel = 
    [CCLabelTTF labelWithString:@"" fontName:@"Verdana" fontSize:[Helper convertFontSize:22]];
    levelCompleteLabel.color = ccc3(255, 255, 255);
    levelCompleteLabel.anchorPoint = ccp(0.5, 1);
    levelCompleteLabel.position = ccp(undercoverSize.width * 0.5, undercoverSize.height * 0.95);

    if ([GameManager sharedGameManager].hasLevelWin)
    {
        // Add sound to WIN LEVEL
        GameManager *gm = [GameManager sharedGameManager];
        const float beginScale = 2;
        [levelCompleteLabel setString:@"Level cleared!"];
        [levelCompleteLabel setColor:ccc3(151, 244, 0)];
        
        // Display positions for Stars
        NSString *starName = @"childcell_idle.png";
        ccBlendFunc blendInactiveStar = (ccBlendFunc){GL_ONE_MINUS_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
        CCSprite *star1 = [CCSprite spriteWithSpriteFrameName:starName];
        CCSprite *star2 = [CCSprite spriteWithSpriteFrameName:starName];
        CCSprite *star3 = [CCSprite spriteWithSpriteFrameName:starName];
        // Star 1
        xButtonPos = levelCompleteLabel.position.x - star1.contentSize.width;
        yButtonPos = levelCompleteLabel.position.y - levelCompleteLabel.contentSize.height * 1.4;
        star1.position = ccp(xButtonPos, yButtonPos);
        // Star 2
        xButtonPos += star1.contentSize.width;
        star2.position = ccp(xButtonPos, yButtonPos);
        // Star 3
        xButtonPos += star1.contentSize.width;
        star3.position = ccp(xButtonPos, yButtonPos);
        star1.blendFunc = blendInactiveStar;
        star2.blendFunc = blendInactiveStar;
        star3.blendFunc = blendInactiveStar;
        star1.scale = beginScale;
        star2.scale = beginScale;
        star3.scale = beginScale;
        star1.opacity = 0;
        star2.opacity = 0;
        star3.opacity = 0;
        [undercover addChild:star1 z:2 tag:kStar1Tag];
        [undercover addChild:star2 z:2 tag:kStar2Tag];
        [undercover addChild:star3 z:2 tag:kStar3Tag];
                
        // Transform Time Value from double to readable format
        double intPart = 0;
        modf(gm.levelElapsedTime, &intPart);
        int isecs = (int)intPart;
        int min = isecs / 60;
        int sec = isecs % 60;
        
        // Create Labels for game stats and score
        CCLabelTTF *goalLabel = 
        [CCLabelTTF labelWithString:@"Goal:" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        CCLabelTTF *goalValue = 
        [CCLabelTTF labelWithString:[NSString stringWithFormat:@" %i", gm.numOfNeededCells] fontName:@"Verdana" fontSize:[Helper convertFontSize:15]];
        CCLabelTTF *collectedLabel = 
        [CCLabelTTF labelWithString:@"Collected:" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        CCLabelTTF *collectedValue = 
        [CCLabelTTF labelWithString:[NSString stringWithFormat:@" %i", gm.numOfSavedCells] fontName:@"Verdana" fontSize:[Helper convertFontSize:15]];
        CCLabelTTF *touchesLabel = 
        [CCLabelTTF labelWithString:@"Touches:" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        CCLabelTTF *touchesValue = 
        [CCLabelTTF labelWithString:[NSString stringWithFormat:@" %i", gm.levelTappedNum] fontName:@"Verdana" fontSize:[Helper convertFontSize:15]];
        CCLabelTTF *timeLabel = 
        [CCLabelTTF labelWithString:@"Time:" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        CCLabelTTF *timeValue = 
        [CCLabelTTF labelWithString:[NSString stringWithFormat:@" %01d:%02d", min, sec] fontName:@"Verdana" fontSize:[Helper convertFontSize:15]];
        CCLabelTTF *scoreLabel = 
        [CCLabelTTF labelWithString:@"Score:" fontName:@"Verdana" fontSize:[Helper convertFontSize:12]];
        CCLabelTTF *scoreValue = 
        [CCLabelTTF labelWithString:[NSString stringWithFormat:@" %i", gm.levelTotalScore] fontName:@"Verdana" fontSize:[Helper convertFontSize:15]];
        
        // Hide labels and color it
        goalLabel.opacity = 0;
        goalValue.opacity = 0;
        collectedLabel.opacity = 0;
        collectedValue.opacity = 0;
        touchesLabel.opacity = 0;
        touchesValue.opacity = 0;
        timeLabel.opacity = 0;
        timeValue.opacity = 0;
        scoreLabel.opacity = 0;
        scoreValue.opacity = 0;
        goalLabel.scale = beginScale;
        goalValue.scale = beginScale;
        collectedLabel.scale = beginScale;
        collectedValue.scale = beginScale;
        touchesLabel.scale = beginScale;
        touchesValue.scale = beginScale;
        timeLabel.scale = beginScale;
        timeValue.scale = beginScale;
        scoreLabel.scale = beginScale;
        scoreValue.scale = beginScale;
        
        // Reconfigu anchor points for alignment
        CGPoint ancVal = ccp(1, 0.5); // Right alignment
        goalLabel.anchorPoint = ancVal;
        collectedLabel.anchorPoint = ancVal;
        touchesLabel.anchorPoint = ancVal;
        timeLabel.anchorPoint = ancVal;
        scoreLabel.anchorPoint = ancVal;
        ancVal = ccp(0, 0.5);   // Left alignment
        goalValue.anchorPoint = ancVal;
        collectedValue.anchorPoint = ancVal;
        touchesValue.anchorPoint = ancVal;
        timeValue.anchorPoint = ancVal;
        scoreValue.anchorPoint = ancVal;
        
        // Adding labels to undercover
        [undercover addChild:scoreLabel];
        [undercover addChild:scoreValue];
        [undercover addChild:goalLabel];
        [undercover addChild:goalValue];
        [undercover addChild:collectedLabel];
        [undercover addChild:collectedValue];
        [undercover addChild:touchesLabel];
        [undercover addChild:touchesValue];
        [undercover addChild:timeLabel];
        [undercover addChild:timeValue];
        
        // Positioning Labels
        // Score
        xButtonPos = undercoverSize.width * 0.5;
        yButtonPos = star1.position.y - undercoverSize.height * 0.14;
        scoreLabel.position = ccp(xButtonPos, yButtonPos);
        scoreValue.position = ccp(xButtonPos, yButtonPos);
        // Goal
        xButtonPos = undercoverSize.width * 0.35;
        yButtonPos = scoreValue.position.y - scoreValue.contentSize.height*1.2;
        goalLabel.position = ccp(xButtonPos, yButtonPos);
        goalValue.position = ccp(xButtonPos, yButtonPos);
        // Collected
        yButtonPos -= goalValue.contentSize.height;
        collectedLabel.position = ccp(xButtonPos, yButtonPos);
        collectedValue.position = ccp(xButtonPos, yButtonPos);
        // Touches
        xButtonPos = undercoverSize.width * 0.75;
        yButtonPos = scoreValue.position.y - scoreValue.contentSize.height*1.2;
        touchesLabel.position = ccp(xButtonPos, yButtonPos);
        touchesValue.position = ccp(xButtonPos, yButtonPos);
        // Time
        yButtonPos -= touchesValue.contentSize.height;        
        timeLabel.position = ccp(xButtonPos, yButtonPos);
        timeValue.position = ccp(xButtonPos, yButtonPos);
        
        // Display Highscore Warning when we update score for this lvl
        if (gm.levelHighScoreAchieved) {
            CCSprite *highscore = [CCSprite spriteWithSpriteFrameName:@"highscore_bubble.png"];
            highscore.opacity = 0;
            highscore.scale = beginScale;
            highscore.position = ccp(undercoverSize.width, undercoverSize.height * 0.5);
            [undercover addChild:highscore];
        }
        
        // Анимируем появление элементов меню
        float delayToPopingUpStars = [self showMenuNodes];
        [self scheduleOnce:@selector(popUpStars) delay:delayToPopingUpStars];
    }
    else
    {
        // Add Sound TO LOSE LEVEL
        [levelCompleteLabel setString:@"Level failed!"];
        [levelCompleteLabel setColor:ccc3(185, 0, 10)];
    }
    
    // Добавляем после анимации, чтобы текст со статусом прохождения уровня и кнопки были без анимации
    [undercover addChild:levelCompleteLabel];
    
    // Menu Buttons
    // Make Sprites for Menu
    CCSprite *resetSprite = [CCSprite spriteWithSpriteFrameName:@"button_reset.png"];
    CCSprite *levelSelectSprite = [CCSprite spriteWithSpriteFrameName:@"button_level_select.png"];
    CCSprite *skipSprite = [CCSprite spriteWithSpriteFrameName:@"button_skip.png"];
    [undercover addChild:levelSelectSprite];
    [undercover addChild:resetSprite];
    [undercover addChild:skipSprite];
    CCMenuItemSpriteIndependent *resetButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:resetSprite selectedSprite:nil target:self selector:@selector(resetPressed)];
    CCMenuItemSpriteIndependent *levelSelectButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:levelSelectSprite selectedSprite:nil target:self selector:@selector(levelSelectPressed)];
    CCMenuItemSpriteIndependent *skipButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:skipSprite selectedSprite:nil target:self selector:@selector(nextPressed)];    
    CCMenu *gameOverMenu = [CCMenu menuWithItems:resetButton, levelSelectButton, skipButton, nil];
    [gameOverMenu setPosition:ccp(0, 0)];
    [undercover addChild:gameOverMenu z:3];
    // Left Down - Level Select
    padding = resetSprite.contentSize.width * 1.5;
    xButtonPos = undercoverSize.width * 0.5 - padding;
    yButtonPos = resetSprite.contentSize.height * 0.5 * 0.4;
    levelSelectSprite.position = ccp(xButtonPos, yButtonPos);
    // Center Down - Reset
    xButtonPos += padding;
    resetSprite.position = ccp(xButtonPos, yButtonPos);
    // Right Down - Skip
    xButtonPos += padding; 
    skipSprite.position = ccp(xButtonPos, yButtonPos);
}

- (float)showMenuNodes
{
    // Последователь скрывает все элементы меню, а затем через определенные промежутки времени показывает их
    float delayTimer = 0;
    float delayInc = 0.1;
    CCNode *undercover = [self getChildByTag:kBackgroundTag];
    
    for (CCNode *tempNode in [undercover children])
    {
        // Объявляем набор анимации элементов меню
        CCFadeIn *fadeAction = [CCFadeIn actionWithDuration:0.6];
        CCScaleTo *scaleDownAction = [CCScaleTo actionWithDuration:0.2 scale:0.5];
        CCScaleTo *scaleUpAction = [CCScaleTo actionWithDuration:0.2 scale:1.2];
        CCScaleTo *scaleDownOriginal = [CCScaleTo actionWithDuration:0.2 scale:1.0];
        CCSequence *scaleUpDownAction = [CCSequence actions:scaleDownAction, scaleUpAction, scaleDownOriginal, nil];
        CCSpawn *spawnAction = [CCSpawn actions:fadeAction, scaleUpDownAction, nil];
        CCDelayTime *delayAction = [CCDelayTime actionWithDuration:delayTimer];
        
        // Запускаем анимацию
        [tempNode runAction:[CCSequence actions:delayAction, spawnAction, nil]];
        
        delayTimer += delayInc;
    }
    return delayTimer;
}

- (void)explodeStar:(CCSprite*)star
{
    // Add Sound to Pop UP THE STAR
    [star setScale:0.1];
    star.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA};
    [star runAction:[CCScaleTo actionWithDuration:0.5 scale:1.2]];
    starEmitter.position = star.position;
    [starEmitter resetSystem];
}

- (void)popUpStars
{
    CCNode *undercover = [self getChildByTag:kBackgroundTag];
    CCSprite *star1 = (CCSprite*) [undercover getChildByTag:kStar1Tag];
    CCSprite *star2 = (CCSprite*) [undercover getChildByTag:kStar2Tag];
    CCSprite *star3 = (CCSprite*) [undercover getChildByTag:kStar3Tag];
    GameManager *gm = [GameManager sharedGameManager];
    starEmitter = [CCParticleSystemQuad particleWithFile:@"ps_popUpStar.plist"];
    [undercover addChild:starEmitter];
    [starEmitter stopSystem];
    CCCallFuncN *explodeStar = [CCCallFuncN actionWithTarget:self selector:@selector(explodeStar:)];
    
    // Display achivied stats
    if (gm.levelStarsNum >= 1)
    {
        [self explodeStar:star1];
        if (gm.levelStarsNum >= 2)
        {
            [star2 runAction:[CCSequence actions:
                              [CCDelayTime actionWithDuration:1],
                              explodeStar,
                              nil]];
            if (gm.levelStarsNum >= 3)
            {
                [star3 runAction:[CCSequence actions:
                                  [CCDelayTime actionWithDuration:2],
                                  explodeStar,
                                  nil]];
            }
        }
    }
}

@end
