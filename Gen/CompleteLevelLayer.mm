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
    CCSpriteBatchNode *levelendBatchNode;
    CCSpriteBatchNode *buttonsBatchNode;
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
//    CGSize screenSize = [CCDirector sharedDirector].winSize;
//    CGSize borderSize = CGSizeMake(screenSize.width, screenSize.height * 0.1);
//    
//    CCTexture2D *borderTex = [self genBorderWithSize:borderSize];
//    CCSprite *borderTop = [CCSprite spriteWithTexture:borderTex];
//    CCSprite *borderBottom = [CCSprite spriteWithTexture:borderTex];
//    borderTop.anchorPoint = ccp(0.5, 0);
//    borderTop.position = ccp(screenSize.width * 0.5, screenSize.height);
//    borderBottom.anchorPoint = ccp(0.5, 1);
//    borderBottom.position = ccp(screenSize.width * 0.5, 0);
//    [self addChild:borderTop];
//    [self addChild:borderBottom];
//    
//    // Actions
//    id callAction = [CCCallFunc actionWithTarget:self selector:@selector(displayGameOverMenuButtons)];
//    CGPoint borderPos = ccp(screenSize.width * 0.5, screenSize.height - [borderTop contentSize].height);
//    [borderTop runAction:[CCMoveTo actionWithDuration:0.5 position:borderPos]];
//    borderPos = ccp(screenSize.width * 0.5, [borderBottom contentSize].height);
//    [borderBottom runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.5 position:borderPos], callAction, nil]];
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
        // pre load the sprite frames from the texture atlas
        levelendBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"menu_levelend_1.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_levelend_1.plist"];
        [self addChild:levelendBatchNode];
        buttonsBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"buttons_sheet_1.pvr.ccz"];
        [self addChild:buttonsBatchNode];
        
        // Опускаем черный рамки сверху и снизу. Как только они на месте - постепенно осветляем фон
//        [self rollBorderFrame];
        [self displayGameOverMenuButtons];
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
    [self runAction:[CCFadeTo actionWithDuration:0.3 opacity:100]];
    
    // Menu undercover
    CCSprite *undercover = [CCSprite spriteWithSpriteFrameName:@"completeMenuUnder.png"];
    undercover.position = ccp(screenSize.width * 0.5, screenSize.height * 0.5);
    [levelendBatchNode addChild:undercover z:0 tag:kBackgroundTag];
    CGSize undercoverSize = undercover.contentSize;
    float undercoverTopBorder = undercover.position.y + undercover.contentSize.height*0.5;
    float undercoverLeftBorder = undercover.position.x - undercover.contentSize.width*0.5;
    
    // Create Label for game status (Win or Lose)
    CCSprite *levelCompleteLabel = [CCSprite node];
    levelCompleteLabel.anchorPoint = ccp(0.5, 0);
    levelCompleteLabel.position = ccp(screenSize.width * 0.5, undercoverTopBorder - levelCompleteLabel.contentSize.height - undercover.contentSize.height * 0.16);
    
    // Create Genby picture (win or lose)
    CCSprite *genbySprite = [CCSprite node];

    if ([GameManager sharedGameManager].hasLevelWin)
    {
        PLAYSOUNDEFFECT(@"LEVELCOMPLETE_WIN");
        GameManager *gm = [GameManager sharedGameManager];
        const float beginScale = 2;
        // Label
        levelCompleteLabel.position = ccp(screenSize.width * 0.52, levelCompleteLabel.position.y);
        [levelCompleteLabel setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"label_level_cleared.png"]];
        // Genby Picture
        [genbySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"genby_level_win.png"]];
        genbySprite.anchorPoint = ccp(0.28, 0);
        genbySprite.position = ccp(undercover.position.x - undercover.contentSize.width*0.5, screenSize.height * 0.49);
        
        // Display positions for Stars
        NSString *starName = @"star_off.png";
        CCSprite *star1 = [CCSprite spriteWithSpriteFrameName:starName];
        CCSprite *star2 = [CCSprite spriteWithSpriteFrameName:starName];
        CCSprite *star3 = [CCSprite spriteWithSpriteFrameName:starName];
        // Star 1
        padding = star1.contentSize.width*1.3;
        xButtonPos = undercover.position.x;
        yButtonPos = levelCompleteLabel.position.y - star1.contentSize.height * 0.9;
        star1.position = ccp(xButtonPos, yButtonPos);
        // Star 2
        xButtonPos += padding;
        star2.position = ccp(xButtonPos, yButtonPos);
        // Star 3
        xButtonPos += padding;
        star3.position = ccp(xButtonPos, yButtonPos);
        star1.scale = beginScale;
        star2.scale = beginScale;
        star3.scale = beginScale;
        star1.opacity = 0;
        star2.opacity = 0;
        star3.opacity = 0;
        [levelendBatchNode addChild:star1 z:2 tag:kStar1Tag];
        [levelendBatchNode addChild:star2 z:2 tag:kStar2Tag];
        [levelendBatchNode addChild:star3 z:2 tag:kStar3Tag];
                
        // Transform Time Value from double to readable format
        double intPart = 0;
        modf(gm.levelElapsedTime, &intPart);
        int isecs = (int)intPart;
        int min = isecs / 60;
        int sec = isecs % 60;
        
        // Create Labels for game stats and score
        float labelFontSize = [Helper convertFontSize:8];
//        float valueFontSize = [Helper convertFontSize:15];
        
        NSString *fontName = @"Tahoma";
        NSString *panelName = @"panel_stats_label.png";
        CCSprite *goalLabelSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        CCSprite *collectedLabelSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        CCSprite *touchesLabelSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        CCSprite *timeLabelSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        CCSprite *scoreLabelSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        panelName = @"panel_stats_value.png";
        CCSprite *goalValueSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        CCSprite *collectedValueSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        CCSprite *touchesValueSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        CCSprite *timeValueSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        panelName = @"panel_score_value.png";
        CCSprite *scoreValueSprite = [CCSprite spriteWithSpriteFrameName:panelName];
        
        CCLabelTTF *goalLabel =
        [CCLabelTTF labelWithString:@"Goal" fontName:fontName fontSize:labelFontSize];
        CCLabelBMFont *goalValue = 
        [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", gm.numOfNeededCells] fntFile:@"levelendScore.fnt"];
        CCLabelTTF *collectedLabel = 
        [CCLabelTTF labelWithString:@"Collected" fontName:fontName fontSize:labelFontSize];
        CCLabelBMFont *collectedValue = 
        [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", gm.numOfSavedCells] fntFile:@"levelendScore.fnt"];
        CCLabelTTF *touchesLabel = 
        [CCLabelTTF labelWithString:@"Touches" fontName:fontName fontSize:labelFontSize];
        CCLabelBMFont *touchesValue = 
        [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", gm.levelTappedNum] fntFile:@"levelendScore.fnt"];
        CCLabelTTF *timeLabel = 
        [CCLabelTTF labelWithString:@"Time" fontName:fontName fontSize:labelFontSize];
        CCLabelBMFont *timeValue = 
        [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%01d:%02d", min, sec] fntFile:@"levelendScore.fnt"];
        CCLabelTTF *scoreLabel = 
        [CCLabelTTF labelWithString:@"Score" fontName:fontName fontSize:labelFontSize];
        CCLabelBMFont *scoreValue =
        [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", gm.levelTotalScore] fntFile:@"levelendScore.fnt"];
        
        // Hide labels and color it
        ccColor3B fontColor = ccc3(90, 90, 90);
        goalValue.opacity = 0;
        collectedValue.opacity = 0;
        touchesValue.opacity = 0;
        timeValue.opacity = 0;
        scoreValue.opacity = 0;
        goalLabel.color = fontColor;
        collectedLabel.color = fontColor;
        touchesLabel.color = fontColor;
        timeLabel.color = fontColor;
        scoreLabel.color = fontColor;
        goalValue.scale = 1.6;
        collectedValue.scale = 1.6;
        touchesValue.scale = 1.6;
        timeValue.scale = 1.6;
        scoreValue.scale = beginScale;
        CGPoint anc = ccp(0.5, 0.67);
        scoreValue.anchorPoint = anc;
        goalValue.anchorPoint = anc;
        collectedValue.anchorPoint = anc;
        touchesValue.anchorPoint = anc;
        timeValue.anchorPoint = anc;
        
        // Adding labels to undercover
        [levelendBatchNode addChild:scoreLabelSprite z:2];
        [levelendBatchNode addChild:scoreValueSprite z:2];
        [levelendBatchNode addChild:goalLabelSprite z:2];
        [levelendBatchNode addChild:goalValueSprite z:2];
        [levelendBatchNode addChild:collectedLabelSprite z:2];
        [levelendBatchNode addChild:collectedValueSprite z:2];
        [levelendBatchNode addChild:touchesLabelSprite z:2];
        [levelendBatchNode addChild:touchesValueSprite z:2];
        [levelendBatchNode addChild:timeLabelSprite z:2];
        [levelendBatchNode addChild:timeValueSprite z:2];
        
        [self addChild:scoreLabel z:3];
        [self addChild:scoreValue z:3];
        [self addChild:goalLabel z:3];
        [self addChild:goalValue z:3];
        [self addChild:collectedLabel z:3];
        [self addChild:collectedValue z:3];
        [self addChild:touchesLabel z:3];
        [self addChild:touchesValue z:3];
        [self addChild:timeLabel z:3];
        [self addChild:timeValue z:3];
        
        // Positioning Labels
        // Score
        xButtonPos = screenSize.width * 0.51;
        yButtonPos = star1.position.y - undercoverSize.height * 0.14;
        padding = scoreLabelSprite.contentSize.width*0.5 + scoreValueSprite.contentSize.width*0.53;
        scoreLabelSprite.position = ccp(xButtonPos, yButtonPos);
        scoreValueSprite.position = ccp(xButtonPos + padding, yButtonPos);
        scoreLabel.position = scoreLabelSprite.position;
        scoreValue.position = scoreValueSprite.position;
        
        // Goal
        xButtonPos = undercoverLeftBorder + goalLabelSprite.contentSize.width*0.5 + undercover.contentSize.width * 0.08;
        yButtonPos -= scoreLabelSprite.contentSize.height * 1.5;
        padding = goalLabelSprite.contentSize.width*0.5 + goalValueSprite.contentSize.width*0.5;
        goalLabelSprite.position = ccp(xButtonPos, yButtonPos);
        goalValueSprite.position = ccp(xButtonPos+padding, yButtonPos);
        goalLabel.position = goalLabelSprite.position;
        goalValue.position = goalValueSprite.position;
        
        // Collected
        yButtonPos -= collectedLabelSprite.contentSize.height * 1.5;
        collectedLabelSprite.position = ccp(xButtonPos, yButtonPos);
        collectedValueSprite.position = ccp(xButtonPos+padding, yButtonPos);
        collectedLabel.position = collectedLabelSprite.position;
        collectedValue.position = collectedValueSprite.position;
        
        // Time
        xButtonPos = screenSize.width * 0.55;
        timeLabelSprite.position = ccp(xButtonPos, yButtonPos);
        timeValueSprite.position = ccp(xButtonPos+padding, yButtonPos);
        timeLabel.position = timeLabelSprite.position;
        timeValue.position = timeValueSprite.position;
        
        // Touches
        yButtonPos = goalLabelSprite.position.y;
        touchesLabelSprite.position = ccp(xButtonPos, yButtonPos);
        touchesValueSprite.position = ccp(xButtonPos+padding, yButtonPos);
        touchesLabel.position = touchesLabelSprite.position;
        touchesValue.position = touchesValueSprite.position;
                
        
        // Display Highscore Warning when we update score for this lvl
        if (gm.levelHighScoreAchieved) {
            CCSprite *highscore = [CCSprite spriteWithSpriteFrameName:@"highscore_bubble.png"];
            highscore.opacity = 0;
            highscore.scale = beginScale;
            highscore.position = ccp(screenSize.width*0.18, screenSize.height * 0.75);
            [levelendBatchNode addChild:highscore z:3];
        }
        
        // Анимируем появление элементов меню
        float delayToPopingUpStars = [self showMenuNodes];
        [self scheduleOnce:@selector(popUpStars) delay:delayToPopingUpStars];
    }
    else
    {
        // Add Sound TO LOSE LEVEL
        PLAYSOUNDEFFECT(@"LEVELCOMPLETE_FAILE");
        [levelCompleteLabel setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"label_level_failed.png"]];
        [genbySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"genby_level_failed.png"]];
        genbySprite.anchorPoint = ccp(0.5, 1);
        genbySprite.position = ccp(levelCompleteLabel.position.x, levelCompleteLabel.position.y);
    }
    
    // Добавляем потому как определяемся с содержимым только после условий
    [levelendBatchNode addChild:levelCompleteLabel];
    [levelendBatchNode addChild:genbySprite];
    
    // Menu Buttons
    // Make Sprites for Menu
    CCSprite *resetSprite = [CCSprite spriteWithSpriteFrameName:@"button_reset.png"];
    CCSprite *levelSelectSprite = [CCSprite spriteWithSpriteFrameName:@"button_level_select.png"];
    CCSprite *skipSprite = [CCSprite spriteWithSpriteFrameName:@"button_skip.png"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        skipSprite.scale = 1.2;
        resetSprite.scale = 1.2;
        levelSelectSprite.scale = 1.2;
    }
    [buttonsBatchNode addChild:levelSelectSprite];
    [buttonsBatchNode addChild:resetSprite];
    [buttonsBatchNode addChild:skipSprite];
    CCMenuItemSpriteIndependent *resetButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:resetSprite selectedSprite:nil target:self selector:@selector(resetPressed)];
    CCMenuItemSpriteIndependent *levelSelectButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:levelSelectSprite selectedSprite:nil target:self selector:@selector(levelSelectPressed)];
    CCMenuItemSpriteIndependent *skipButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:skipSprite selectedSprite:nil target:self selector:@selector(nextPressed)];    
    CCMenu *gameOverMenu = [CCMenu menuWithItems:resetButton, levelSelectButton, skipButton, nil];
    [gameOverMenu setPosition:ccp(0, 0)];
    [self addChild:gameOverMenu z:3];
    // Left Down - Level Select
    padding = resetSprite.contentSize.width * 1.5;
    xButtonPos = screenSize.width * 0.5 - padding;
    yButtonPos = undercover.position.y - undercoverSize.height*0.5 + resetSprite.contentSize.height*0.95;
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
    
    // Показываем графику из батча
    for (CCSprite *tempNode in [levelendBatchNode children])
    {
        if (tempNode.opacity == 0) {
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
    }
    
    // Показываем текст статистики
    for (CCNode *tempNode in [self children])
    {
        if ([tempNode isKindOfClass:[CCLabelTTF class]] || [tempNode isKindOfClass:[CCLabelBMFont class]]) {
            // Объявляем набор анимации элементов меню
            if (tempNode.scale > 1) {
                CCFadeIn *fadeAction = [CCFadeIn actionWithDuration:0.6];
                CCScaleTo *scaleDownAction = [CCScaleTo actionWithDuration:0.2 scale:tempNode.scale/4];
                CCScaleTo *scaleUpAction = [CCScaleTo actionWithDuration:0.2 scale:tempNode.scale/2*1.2];
                CCScaleTo *scaleDownOriginal = [CCScaleTo actionWithDuration:0.2 scale:tempNode.scale/2];
                CCSequence *scaleUpDownAction = [CCSequence actions:scaleDownAction, scaleUpAction, scaleDownOriginal, nil];
                CCSpawn *spawnAction = [CCSpawn actions:fadeAction, scaleUpDownAction, nil];
                CCDelayTime *delayAction = [CCDelayTime actionWithDuration:delayTimer];
                
                // Запускаем анимацию
                [tempNode runAction:[CCSequence actions:delayAction, spawnAction, nil]];
                
                delayTimer += delayInc;
            }
        }
    }
    
    return delayTimer;
}

- (void)explodeStar:(CCSprite*)star
{
    // Add Sound to Pop UP THE STAR
    [star setScale:0.1];
    [star setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"star_on.png"]];
    [star runAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
    starEmitter.position = star.position;
    [starEmitter resetSystem];
}

- (void)popUpStars
{
    CCSprite *star1 = (CCSprite*) [levelendBatchNode getChildByTag:kStar1Tag];
    CCSprite *star2 = (CCSprite*) [levelendBatchNode getChildByTag:kStar2Tag];
    CCSprite *star3 = (CCSprite*) [levelendBatchNode getChildByTag:kStar3Tag];
    GameManager *gm = [GameManager sharedGameManager];
    starEmitter = [CCParticleSystemQuad particleWithFile:@"ps_popUpStar.plist"];
    [self addChild:starEmitter];
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
