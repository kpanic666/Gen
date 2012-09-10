//
//  MainMenuLayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameManager.h"
#import "GCHelper.h"
#import "GameState.h"
#import "CCMenuItemSpriteIndependent.h"
#import "ChildCell.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#define kInfoSpriteTag 9
#define kPanelSpriteTag 10
#define kOptionsSpriteTag 11
#define kMusicToggleTag 12
#define kSfxToggleTag 13

@interface MainMenuLayer()
{
    CCSpriteBatchNode *sceneSpriteBatchNode;
    CCMenu *optionsMenu;
    CCMenu *mainMenu;
}
- (void)displayMainMenuButtons;
- (void)displayOptionsMenuButtons;
@end

@implementation MainMenuLayer

uint fallenBlocksFreq = 8;  // Частота выпадения еды (больше - реже)
uint fallenBlocksCounter = 0;  // Счетчик частоты выпадения еды.

+ (id)scene {
    CCScene *scene = [CCScene node];
    MainMenuLayer *mainMenuLayer = [self node];
    [scene addChild:mainMenuLayer];
    return scene;
}

- (void)playPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [[GameManager sharedGameManager] runSceneWithID:kLevelSelectScene];
}

- (void)optionsPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [self displayOptionsMenuButtons];
}

- (void)leaderboardPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardViewController != NULL) {
        leaderboardViewController.leaderboardDelegate = self;
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        [[app navController] presentModalViewController:leaderboardViewController animated:YES];
    }
    
    [leaderboardViewController release];
}

- (void)achievementPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    
    GKAchievementViewController *achievementViewController = [[GKAchievementViewController alloc] init];
    if (achievementViewController != NULL) {
        achievementViewController.achievementDelegate = self;
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        [[app navController] presentModalViewController:achievementViewController animated:YES];
    }
    
    [achievementViewController release];
}

- (void)showCredits
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    // Delete on RELEASE
    [[GCHelper sharedInstance] resetAchievements];
    [[GameState sharedInstance] resetState];
    
//    CCLOG(@"OptionsMenu->Info Button Pressed!");
//	[[GameManager sharedGameManager] runSceneWithID:kCreditsScene];
}

- (void)musicTogglePressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
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
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    CCLOG(@"OptionsMenu->SFX Button Pressed!");
	if ([[GameManager sharedGameManager] isSoundEffectsON]) {
		CCLOG(@"OptionsLayer-> Turning Sound Effects OFF");
		[[GameManager sharedGameManager] setIsSoundEffectsON:NO];
	} else {
		CCLOG(@"OptionsLayer-> Turning Sound Effects ON");
		[[GameManager sharedGameManager] setIsSoundEffectsON:YES];
	}
}

- (void)removeOptionsMenu
{
    CCSprite *infoSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kInfoSpriteTag];
    CCSprite *panelSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kPanelSpriteTag];
    [infoSprite removeFromParentAndCleanup:YES];
    [panelSprite removeFromParentAndCleanup:YES];
    [optionsMenu removeFromParentAndCleanup:YES];
    optionsMenu = nil;
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void)displayOptionsMenuButtons
{
    CCSprite *optionsSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kOptionsSpriteTag];
    CCHide *hideAction = [CCHide action]; 
    
    if (optionsMenu != nil)
    {
        CCMenuItemToggle *musicToggle = (CCMenuItemToggle*) [optionsMenu getChildByTag:kMusicToggleTag];
        CCMenuItemToggle *sfxToggle = (CCMenuItemToggle*) [optionsMenu getChildByTag:kSfxToggleTag];
        CCSprite *infoSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kInfoSpriteTag];
        CCSprite *panelSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kPanelSpriteTag];
        
        CCCallFunc *removeMenuAction = [CCCallFunc actionWithTarget:self selector:@selector(removeOptionsMenu)];
        CCMoveTo *move1Action = [CCMoveTo actionWithDuration:0.2 position:optionsSprite.position];
        CCMoveTo *move2Action = [CCMoveTo actionWithDuration:0.3 position:optionsSprite.position];
        CCMoveTo *move3Action = [CCMoveTo actionWithDuration:0.4 position:optionsSprite.position];
        CCScaleTo *scaleAction = [CCScaleTo actionWithDuration:0.4 scaleX:1 scaleY:0.5];
        [panelSprite runAction:[CCSequence actions:scaleAction, removeMenuAction, nil]];
        [sfxToggle runAction:[CCSequence actions:move1Action, hideAction, nil]];
        [musicToggle runAction:[CCSequence actions:move2Action, hideAction, nil]];
        [infoSprite runAction:[CCSequence actions:move3Action, hideAction, nil]];
    }
    else 
    {
        // Make Sprites for Menu
        CCSprite *musicOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_on.png"];
        CCSprite *musicOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_off.png"];
        CCSprite *sfxOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_on.png"];
        CCSprite *sfxOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_off.png"];
        CCSprite *infoSprite = [CCSprite spriteWithSpriteFrameName:@"button_info.png"];
        CCSprite *panelSprite = [CCSprite spriteWithSpriteFrameName:@"optionsButtonUnder.png"];
        
        // Adding sprites to Batchnode
        [sceneSpriteBatchNode addChild:panelSprite z:1 tag:kPanelSpriteTag];
        [sceneSpriteBatchNode addChild:infoSprite z:3 tag:kInfoSpriteTag];
        
        // Options Menu Items
        CCMenuItemSprite *sfxOnButton = [CCMenuItemSprite itemWithNormalSprite:sfxOnSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSprite *sfxOffButton = [CCMenuItemSprite itemWithNormalSprite:sfxOffSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSprite *musicOnButton = [CCMenuItemSprite itemWithNormalSprite:musicOnSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSprite *musicOffButton = [CCMenuItemSprite itemWithNormalSprite:musicOffSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSpriteIndependent *infoButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:infoSprite selectedSprite:nil target:self selector:@selector(showCredits)];
        CCMenuItemToggle *musicToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicTogglePressed) items:musicOnButton, musicOffButton, nil];
        CCMenuItemToggle *sfxToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(SFXTogglePressed) items:sfxOnButton, sfxOffButton, nil];
        
        optionsMenu = [CCMenu menuWithItems:musicToggle, sfxToggle, infoButton, nil];
        [optionsMenu setPosition:ccp(0, 0)];
        [self addChild:optionsMenu z:3];
        
        // Hide and scale down sprites for Options Menu
        float padding = 0.8;
        [musicToggle setScale:padding];
        [sfxToggle setScale:padding];
        [infoSprite setScale:padding];
        [panelSprite setAnchorPoint:ccp(0.5, 0)];
        [musicToggle setTag:kMusicToggleTag];
        [sfxToggle setTag:kSfxToggleTag];
        
        // Positioning sprites
        float xButtonPos = 0;
        float yButtonPos = 0;
        xButtonPos = optionsSprite.position.x;
        yButtonPos = optionsSprite.position.y;
        [panelSprite setPosition:ccp(xButtonPos, yButtonPos)];
        padding = optionsSprite.contentSize.height;
        yButtonPos += padding;
        sfxToggle.position = ccp(xButtonPos, yButtonPos);
        yButtonPos += padding;
        musicToggle.position = ccp(xButtonPos, yButtonPos);
        yButtonPos += padding;
        [infoSprite setPosition:ccp(xButtonPos, yButtonPos)];
        
        if ([[GameManager sharedGameManager] isMusicON] == NO) {
            [musicToggle setSelectedIndex:1]; // Music is OFF
        }
        if ([[GameManager sharedGameManager] isSoundEffectsON] == NO) {
            [sfxToggle setSelectedIndex:1]; // SFX are OFF
        }
        
        // Animating open menu
        CCShow *showAction = [CCShow action];
        CCDelayTime *delay1Action = [CCDelayTime actionWithDuration:0.1];
        CCDelayTime *delay2Action = [CCDelayTime actionWithDuration:0.2];
        CCDelayTime *delay3Action = [CCDelayTime actionWithDuration:0.3];
        [panelSprite runAction:[CCScaleTo actionWithDuration:0.2 scaleX:1 scaleY:5]];
        [sfxToggle runAction:[CCSequence actions:hideAction, delay1Action ,showAction, nil]];
        [musicToggle runAction:[CCSequence actions:hideAction, delay2Action, showAction, nil]];
        [infoSprite runAction:[CCSequence actions:hideAction, delay3Action, showAction, nil]];  
    }
}

- (void)displayMainMenuButtons
{
    // Make Sprites for Menu
    CCSprite *playGameSprite = [CCSprite spriteWithSpriteFrameName:@"button_big_play.png"];
    CCSprite *optionsSprite = [CCSprite spriteWithSpriteFrameName:@"button_options.png"];
    CCSprite *leaderboardSprite = [CCSprite spriteWithSpriteFrameName:@"button_leaderboard.png"];
    CCSprite *achievmentsSprite = [CCSprite spriteWithSpriteFrameName:@"button_achievments.png"];
    
    // Positioning sprites
    float padding = [optionsSprite contentSize].width*0.5 * 0.2; // отступ от края экрана c учетом спец эффекта меню
    float xButtonPos = 0;
    float yButtonPos = 0;
    [playGameSprite setPosition:ccp(screenSize.width*0.78, screenSize.height*0.47)];
    xButtonPos = screenSize.width-[optionsSprite contentSize].width*0.5 - padding;
    yButtonPos = [optionsSprite contentSize].height*0.5 + padding;
    [optionsSprite setPosition:ccp(xButtonPos, yButtonPos)];
    xButtonPos = screenSize.width*0.5-([leaderboardSprite contentSize].width + padding);
    yButtonPos = [leaderboardSprite contentSize].height*0.5 + padding;
    [leaderboardSprite setPosition:ccp(xButtonPos, yButtonPos)];
    xButtonPos = screenSize.width*0.5+([achievmentsSprite contentSize].width + padding);
    yButtonPos = [achievmentsSprite contentSize].height*0.5 + padding;
    [achievmentsSprite setPosition:ccp(xButtonPos, yButtonPos)];

    // Adding sprites to Batchnode
    [sceneSpriteBatchNode addChild:playGameSprite z:3];
    [sceneSpriteBatchNode addChild:optionsSprite z:3 tag:kOptionsSpriteTag];
    [sceneSpriteBatchNode addChild:leaderboardSprite z:3];
    [sceneSpriteBatchNode addChild:achievmentsSprite z:3];
    
    // Main Menu Items
    CCMenuItemSpriteIndependent *playGameButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:playGameSprite selectedSprite:nil target:self selector:@selector(playPressed)];
    CCMenuItemSpriteIndependent *optionsButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:optionsSprite selectedSprite:nil target:self selector:@selector(optionsPressed)];
    CCMenuItemSpriteIndependent *leaderboardButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:leaderboardSprite selectedSprite:nil target:self selector:@selector(leaderboardPressed)];
    CCMenuItemSpriteIndependent *achievementButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:achievmentsSprite selectedSprite:nil target:self selector:@selector(achievementPressed)];

    mainMenu = [CCMenu menuWithItems:playGameButton, optionsButton, leaderboardButton, achievementButton,nil];
    [self addChild:mainMenu z:5];
    
    // Animate play button
    [playGameSprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                            [CCScaleTo actionWithDuration:0.5 scale:0.9],
                            [CCScaleTo actionWithDuration:0.5 scale:1], nil]]];
}

- (void)setupWorld
{
    b2Vec2 gravity;
    gravity.Set(0.0f, -7.0f);
    world = new b2World(gravity);
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(TRUE);
	world->SetContinuousPhysics(TRUE);
}

- (void)createGround:(CGPoint)location
{
    int num = 22;
    b2Vec2 verts[] = {
        b2Vec2(249.6f / 64.0, 23.7f / 64.0),
        b2Vec2(239.2f / 64.0, 47.4f / 64.0),
        b2Vec2(215.8f / 64.0, 59.3f / 64.0),
        b2Vec2(190.6f / 64.0, 61.8f / 64.0),
        b2Vec2(175.5f / 64.0, 47.1f / 64.0),
        b2Vec2(162.0f / 64.0, 45.3f / 64.0),
        b2Vec2(140.4f / 64.0, 62.7f / 64.0),
        b2Vec2(110.2f / 64.0, 69.1f / 64.0),
        b2Vec2(93.3f / 64.0, 64.4f / 64.0),
        b2Vec2(64.0f / 64.0, 71.3f / 64.0),
        b2Vec2(26.9f / 64.0, 60.2f / 64.0),
        b2Vec2(-0.6f / 64.0, 68.1f / 64.0),
        b2Vec2(-10.2f / 64.0, 62.6f / 64.0),
        b2Vec2(-26.1f / 64.0, 55.5f / 64.0),
        b2Vec2(-61.4f / 64.0, 73.9f / 64.0),
        b2Vec2(-90.7f / 64.0, 74.8f / 64.0),
        b2Vec2(-112.7f / 64.0, 81.4f / 64.0),
        b2Vec2(-178.9f / 64.0, 62.8f / 64.0),
        b2Vec2(-221.3f / 64.0, 72.2f / 64.0),
        b2Vec2(-265.0f / 64.0, 54.0f / 64.0),
        b2Vec2(-285.3f / 64.0, 31.5f / 64.0),
        b2Vec2(-299.2f / 64.0, -14.3f / 64.0)
    };
    
    b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
    groundBodyDef.position.Set(location.x / PTM_RATIO, location.y / PTM_RATIO);
    groundBody = world->CreateBody(&groundBodyDef);
    b2EdgeShape groundShape;
    b2FixtureDef groundFixtureDef;
    groundFixtureDef.shape = &groundShape;
    for (int i = 0; i < num-1; ++i) {
        b2Vec2 left = verts[i];
        b2Vec2 right = verts[i+1];
        groundShape.Set(left, right);
        groundBody->CreateFixture(&groundFixtureDef);
    }
}

- (void)createFood
{
    CGPoint location = ccp(screenSize.width/4 + random() % (int)screenSize.width / 2, screenSize.height);
//    CGPoint location = ccp(screenSize.width/2, screenSize.height/2);
    ChildCell *childCell = [[[ChildCell alloc] initWithWorld:world atLocation:location] autorelease];
    childCell.body->SetSleepingAllowed(YES);
    childCell.body->SetLinearDamping(0);
    [sceneSpriteBatchNode addChild:childCell z:1];
}

- (id)init {
    if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode z:1];
        
        // Background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"mainmenu_back.png"];
        [background setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
        [self addChild:background z:-1];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Logo
        CCSprite *genbyLogo = [CCSprite spriteWithSpriteFrameName:@"genby_logo.png"];
        genbyLogo.position = ccp(screenSize.width*0.46, screenSize.height*0.52);
        [self addChild:genbyLogo z:5];
        
        // Add physics falling down food
        [self setupWorld];
        [self createGround:genbyLogo.position];
        [self scheduleUpdate];
        
        // Liquid Effect for layer
//        CCLiquid *liquidEffect = [CCLiquid actionWithWaves:7 amplitude:2 grid:ccg(16, 16) duration:10];
//        [background runAction:[CCRepeatForever actionWithAction:liquidEffect]];
        
        // Display Main Menu Buttons
        [self displayMainMenuButtons];
        
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_1];
    }
    return self;
}

- (void)dealloc
{
    delete world;
    world = NULL;
    
    [super dealloc];
}

- (void)update:(ccTime)dt
{
    // Выпадаем еду
    if (fallenBlocksCounter > fallenBlocksFreq) {
        fallenBlocksCounter = 0;
        [self createFood];
    }
    fallenBlocksCounter++;
    
	// Update Box2D World: Fixed Time Step
    static double UPDATE_INTERVAL = 1.0f/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    timeAccumulator += dt;
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)) {
        timeAccumulator = UPDATE_INTERVAL;
    }
    
    int32 velocityIterations = 8;
    int32 positionIterations = 3;
    while (timeAccumulator >= UPDATE_INTERVAL) {
        timeAccumulator -= UPDATE_INTERVAL;
        world->Step(UPDATE_INTERVAL, velocityIterations, positionIterations);
    }
    
    // Adjust sprite for physics bodies
    for (b2Body *b = world->GetBodyList(); b != NULL; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            Box2DSprite *sprite = (Box2DSprite*) b->GetUserData();
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            sprite.rotation = CC_RADIANS_TO_DEGREES(b->GetAngle() * -1);
            //если тело за пределами экрана - убиваем его и его мувик
            if (sprite.position.y < 0) {
                [sprite removeFromParentAndCleanup:YES];
                world->DestroyBody(b);
            }
        }
    }
}


@end
