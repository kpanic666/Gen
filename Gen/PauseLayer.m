//
//  PauseLayer.m
//  Gen
//
//  Created by Andrey Korikov on 02.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "PauseLayer.h"
#import "GameManager.h"
#import "CCMenuItemSpriteIndependent.h"

#define kBackgroundSpriteTag 9

@interface PauseLayer()
{
    CCSpriteBatchNode *pauseBatchNode;
    CCMenu *pauseMenu;
}
- (void)displayPauseMenuButtons;
@end

@implementation PauseLayer

- (id)initWithColor:(ccColor4B)color
{
    if ((self = [super initWithColor:color]))
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        // Background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
        CCSprite *background = [CCSprite spriteWithFile:@"pauseMenuBack.jpg"];
        background.anchorPoint = ccp(1, 1);
        background.position = ccp(screenSize.width + background.contentSize.width, screenSize.height);
        [self addChild:background z:0 tag:kBackgroundSpriteTag];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        pauseBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [background addChild:pauseBatchNode];
        
        // Move background undercover to it's work position
        [background runAction:[CCMoveTo actionWithDuration:0.2 position:ccp(screenSize.width, screenSize.height)]];
        
        // Display Main Menu Buttons
        [self displayPauseMenuButtons];
    }
    return self;
}

- (void)levelSelectPressed
{
    [[GameManager sharedGameManager] runSceneWithID:kLevelSelectScene];
}

- (void)resetPressed
{
    GameManager *gameManager = [GameManager sharedGameManager];
    [gameManager runSceneWithID:gameManager.curLevel];
}

- (void)resumePressed
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background = (CCSprite*)[self getChildByTag:kBackgroundSpriteTag];
    CCLayer *gl = (CCLayer*) [self.parent getChildByTag:kBox2DLayer];
    [gl resumeSchedulerAndActions];
    CCMoveTo *moveAction = [CCMoveTo actionWithDuration:0.2 position:ccp(screenSize.width + background.contentSize.width, screenSize.height)];
    CCCallFunc *callAction = [CCCallFunc actionWithTarget:self selector:@selector(removeFromParentAndCleanup:)];
    [background runAction:[CCSequence actions:moveAction, callAction, nil]];
}

- (void)musicTogglePressed
{
	if ([[GameManager sharedGameManager] isMusicON]) {
		CCLOG(@"OptionsLayer-> Turning Game Music OFF");
		[[GameManager sharedGameManager] setMusicState:NO];
	} else {
		CCLOG(@"OptionsLayer-> Turning Game Music ON");
		[[GameManager sharedGameManager] setMusicState:YES];
	}
}

- (void)SFXTogglePressed
{
    CCLOG(@"OptionsMenu->SFX Button Pressed!");
	if ([[GameManager sharedGameManager] isSoundEffectsON]) {
		CCLOG(@"OptionsLayer-> Turning Sound Effects OFF");
		[[GameManager sharedGameManager] setIsSoundEffectsON:NO];
	} else {
		CCLOG(@"OptionsLayer-> Turning Sound Effects ON");
		[[GameManager sharedGameManager] setIsSoundEffectsON:YES];
	}
}

- (void)displayPauseMenuButtons
{
    CCSprite *background = (CCSprite*)[self getChildByTag:kBackgroundSpriteTag];
    CGSize backSize = background.contentSize;
    
    // Make Sprites for Menu
    CCSprite *musicOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_on.png"];
    CCSprite *musicOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_off.png"];
    CCSprite *sfxOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_on.png"];
    CCSprite *sfxOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_off.png"];
    CCSprite *resumeSprite = [CCSprite spriteWithSpriteFrameName:@"button_resume.png"];
    CCSprite *resetSprite = [CCSprite spriteWithSpriteFrameName:@"button_reset.png"];
    CCSprite *levelSelectSprite = [CCSprite spriteWithSpriteFrameName:@"button_level_select.png"];
    CCSprite *skipSprite = [CCSprite spriteWithSpriteFrameName:@"button_skip.png"];
    
    // Adding sprites to Batchnode
    [pauseBatchNode addChild:resumeSprite];
    [pauseBatchNode addChild:resetSprite];
    [pauseBatchNode addChild:levelSelectSprite];
    [pauseBatchNode addChild:skipSprite];
    
    // Options Menu Items
    CCMenuItemSprite *sfxOnButton = [CCMenuItemSprite itemWithNormalSprite:sfxOnSprite selectedSprite:nil target:self selector:nil];
    CCMenuItemSprite *sfxOffButton = [CCMenuItemSprite itemWithNormalSprite:sfxOffSprite selectedSprite:nil target:self selector:nil];
    CCMenuItemSprite *musicOnButton = [CCMenuItemSprite itemWithNormalSprite:musicOnSprite selectedSprite:nil target:self selector:nil];
    CCMenuItemSprite *musicOffButton = [CCMenuItemSprite itemWithNormalSprite:musicOffSprite selectedSprite:nil target:self selector:nil];
    CCMenuItemSpriteIndependent *resumeButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:resumeSprite selectedSprite:nil target:self selector:@selector(resumePressed)];
    CCMenuItemSpriteIndependent *resetButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:resetSprite selectedSprite:nil target:self selector:@selector(resetPressed)];
    CCMenuItemSpriteIndependent *levelSelectButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:levelSelectSprite selectedSprite:nil target:self selector:@selector(levelSelectPressed)];
    CCMenuItemSpriteIndependent *skipButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:skipSprite selectedSprite:nil target:self selector:@selector(resumePressed)];
    CCMenuItemToggle *musicToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicTogglePressed) items:musicOnButton, musicOffButton, nil];
    CCMenuItemToggle *sfxToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(SFXTogglePressed) items:sfxOnButton, sfxOffButton, nil];
    
    pauseMenu = [CCMenu menuWithItems:musicToggle, sfxToggle, resumeButton, resetButton, levelSelectButton, skipButton, nil];
    [pauseMenu setPosition:ccp(0, 0)];
    [background addChild:pauseMenu z:3];
    
    // Hide and scale down sprites for Options Menu
    float padding = 0.8;
//    [musicToggle setScale:padding];
//    [sfxToggle setScale:padding];
//    [musicToggle setTag:kMusicToggleTag];
//    [sfxToggle setTag:kSfxToggleTag];
    
    // Positioning sprites
    padding = [resumeSprite contentSize].width*0.5 * 0.2; // отступ от края экрана c учетом спец эффекта меню
    float xButtonPos = 0;
    float yButtonPos = 0;
    // Left Down - SFX
    xButtonPos = padding + sfxToggle.contentSize.width * 0.5;
    yButtonPos = padding + sfxToggle.contentSize.height * 0.5;
    sfxToggle.position = ccp(xButtonPos, yButtonPos);
    // Right Down - Music
    xButtonPos = backSize.width - padding - musicToggle.contentSize.width * 0.5;
    musicToggle.position = ccp(xButtonPos, yButtonPos);
    // Right Up - Resume
    yButtonPos = backSize.height - padding - resumeSprite.contentSize.height * 0.5; 
    resumeSprite.position = ccp(xButtonPos, yButtonPos);
    // Center - Level Select
    xButtonPos = backSize.width * 0.5;
    yButtonPos = backSize.height * 0.5;
    levelSelectSprite.position = ccp(xButtonPos, yButtonPos);
    // Center UP - Reset
    padding += resetSprite.contentSize.height;
    yButtonPos += padding;
    resetSprite.position = ccp(xButtonPos, yButtonPos);
    // Center Down - Skip
    yButtonPos -= padding * 2;
    skipSprite.position = ccp(xButtonPos, yButtonPos);
    
    if ([[GameManager sharedGameManager] isMusicON] == NO) {
        [musicToggle setSelectedIndex:1]; // Music is OFF
    }
    if ([[GameManager sharedGameManager] isSoundEffectsON] == NO) {
        [sfxToggle setSelectedIndex:1]; // SFX are OFF
    }
    
    // Animating open menu
//    CCShow *showAction = [CCShow action];
//    CCDelayTime *delay1Action = [CCDelayTime actionWithDuration:0.1];
//    CCDelayTime *delay2Action = [CCDelayTime actionWithDuration:0.2];
//    CCDelayTime *delay3Action = [CCDelayTime actionWithDuration:0.3];
//    [panelSprite runAction:[CCScaleTo actionWithDuration:0.2 scaleX:1 scaleY:5]];
//    [sfxToggle runAction:[CCSequence actions:hideAction, delay1Action ,showAction, nil]];
//    [musicToggle runAction:[CCSequence actions:hideAction, delay2Action, showAction, nil]];
//    [infoSprite runAction:[CCSequence actions:hideAction, delay3Action, showAction, nil]];  
}

@end
