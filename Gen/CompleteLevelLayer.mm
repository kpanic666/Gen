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

@interface CompleteLevelLayer()
{
    CCSpriteBatchNode *gameOverBatchNode;
    CCMenu *gameOverMenu;
}
- (void)displayGameOverMenuButtons;
- (void)rollBorderFrame;
- (CCTexture2D*)genBorderWithSize:(CGSize)textureSize;
@end

@implementation CompleteLevelLayer

- (void)rollBorderFrame
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGSize borderSize = CGSizeMake(screenSize.width, screenSize.height * 0.2);
    
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
        
        gameOverBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [self addChild:gameOverBatchNode z:5];
    }
    return self;
}

- (void)levelSelectPressed
{
    [[GameManager sharedGameManager] runSceneWithID:kLevelSelectScene];
}

- (void)resetPressed
{
    [[GameManager sharedGameManager] reloadCurrentScene];
}

- (void)nextPressed
{
    [[GameManager sharedGameManager] runNextScene];
}

- (void)displayGameOverMenuButtons
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // Fade Out self layer color to 50% transperency
    [self runAction:[CCFadeTo actionWithDuration:0.3 opacity:128]];
    
    // Menu undercover
    CCSprite *undercover = [CCSprite spriteWithFile:@"completeMenuUnder.png"];
    undercover.position = ccp(screenSize.width * 0.5, screenSize.height * 0.5);
    [self addChild:undercover];
    
    // Create Top Label with level complete status
    CCLabelTTF *levelCompleteLabel = [CCLabelTTF labelWithString:@"" fontName:@"Verdana" fontSize:[Helper convertFontSize:22]];
    levelCompleteLabel.color = ccc3(255, 255, 255);
    levelCompleteLabel.anchorPoint = ccp(0.5, 1);
    [undercover addChild:levelCompleteLabel];

    // Make Sprites for Menu
    CCSprite *resetSprite = [CCSprite spriteWithSpriteFrameName:@"button_reset.png"];
    CCSprite *levelSelectSprite = [CCSprite spriteWithSpriteFrameName:@"button_level_select.png"];
    CCSprite *skipSprite = [CCSprite spriteWithSpriteFrameName:@"button_skip.png"];
    // Stars
    NSString *starName = @"childcell_idle.png"; 
    CCSprite *star1 = [CCSprite spriteWithSpriteFrameName:starName];
    CCSprite *star2 = [CCSprite spriteWithSpriteFrameName:starName];
    CCSprite *star3 = [CCSprite spriteWithSpriteFrameName:starName];
    
    // Adding sprites to Batchnode
    [gameOverBatchNode addChild:resetSprite];
    [gameOverBatchNode addChild:levelSelectSprite];
    [gameOverBatchNode addChild:skipSprite];
    [gameOverBatchNode addChild:star1];
    [gameOverBatchNode addChild:star2];
    [gameOverBatchNode addChild:star3];
    
    // Options Menu Items
    CCMenuItemSpriteIndependent *resetButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:resetSprite selectedSprite:nil target:self selector:@selector(resetPressed)];
    CCMenuItemSpriteIndependent *levelSelectButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:levelSelectSprite selectedSprite:nil target:self selector:@selector(levelSelectPressed)];
    CCMenuItemSpriteIndependent *skipButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:skipSprite selectedSprite:nil target:self selector:@selector(nextPressed)];    
    gameOverMenu = [CCMenu menuWithItems:resetButton, levelSelectButton, skipButton, nil];
    [gameOverMenu setPosition:ccp(0, 0)];
    [self addChild:gameOverMenu z:3];
    
    // Positioning sprites
    float padding = [resetSprite contentSize].width*0.5 * 0.3; // отступ от края экрана c учетом спец эффекта меню
    float xButtonPos = 0;
    float yButtonPos = 0;
    // Level complete status label
    levelCompleteLabel.position = ccp(undercover.contentSize.width*0.5, undercover.contentSize.height - padding);
    // Star2
    xButtonPos = undercover.position.x;
    yButtonPos = undercover.position.y + star1.contentSize.height * 1.5;
    star2.position = ccp(xButtonPos, yButtonPos);
    // Star 3
    xButtonPos += star1.contentSize.width;
    star3.position = ccp(xButtonPos, yButtonPos);
    // Star 1
    xButtonPos -= star1.contentSize.width * 2;
    star1.position = ccp(xButtonPos, yButtonPos);
    // Center Down - Reset
    padding = [resetSprite contentSize].width*0.5 * 0.5;
    xButtonPos = screenSize.width * 0.5;
    yButtonPos = (undercover.position.y - undercover.contentSize.height*0.5) + padding;
    resetSprite.position = ccp(xButtonPos, yButtonPos);
    // Right Down - Skip
    xButtonPos += resetSprite.contentSize.width * 1.5;
    skipSprite.position = ccp(xButtonPos, yButtonPos);
    // Left Down - Level Select
    xButtonPos -= resetSprite.contentSize.width * 3; 
    levelSelectSprite.position = ccp(xButtonPos, yButtonPos);

    if ([GameManager sharedGameManager].hasLevelWin)
    {
        [levelCompleteLabel setString:@"Level cleared!"];
    }
    else
    {
        [levelCompleteLabel setString:@"Level failed!"];
    }   
}

@end
