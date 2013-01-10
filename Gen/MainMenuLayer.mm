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
#import "GB2ShapeCache.h"
#import "IAPHelper.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#define kInfoSpriteTag 9
#define kPanelSpriteTag 10
#define kOptionsSpriteTag 11
#define kMusicToggleTag 12
#define kSfxToggleTag 13
#define kRestorePurchaseSpriteTag 14

@interface MainMenuLayer()
{
    CCSpriteBatchNode *sceneSpriteBatchNode;
    CCSpriteBatchNode *buttonsBatchNode;
    CCMenu *optionsMenu;
    CCMenu *mainMenu;
}
- (void)displayMainMenuButtons;
- (void)displayOptionsMenuButtons;
@end

@implementation MainMenuLayer

uint fallenBlocksFreq = 16;  // Частота выпадения еды (больше - реже)
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

- (void)restorePurchasePressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    
    [[IAPHelper sharedInstance] restorePreviousTransactionsOnComplete:^
     {
         
     }
                                                              onError:^(NSError *error)
     {
         
     }];
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

- (void)showCredits
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    // Delete on RELEASE
    [[GCHelper sharedInstance] resetAchievements];
    [[GameState sharedInstance] resetState];
    [[IAPHelper sharedInstance] removeAllKeychainData];
    
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
    CCSprite *infoSprite = (CCSprite*)[buttonsBatchNode getChildByTag:kInfoSpriteTag];
    CCSprite *restoreSprite = (CCSprite*)[buttonsBatchNode getChildByTag:kRestorePurchaseSpriteTag];
    CCSprite *panelSprite = (CCSprite*)[buttonsBatchNode getChildByTag:kPanelSpriteTag];
    [infoSprite removeFromParentAndCleanup:YES];
    [restoreSprite removeFromParentAndCleanup:YES];
    [panelSprite removeFromParentAndCleanup:YES];
    [optionsMenu removeFromParentAndCleanup:YES];
    optionsMenu = nil;
}

- (void)displayOptionsMenuButtons
{
    CCSprite *optionsSprite = (CCSprite*)[buttonsBatchNode getChildByTag:kOptionsSpriteTag];
    CCHide *hideAction = [CCHide action]; 
    
    if (optionsMenu != nil)
    {
        CCMenuItemToggle *musicToggle = (CCMenuItemToggle*) [optionsMenu getChildByTag:kMusicToggleTag];
        CCMenuItemToggle *sfxToggle = (CCMenuItemToggle*) [optionsMenu getChildByTag:kSfxToggleTag];
        CCSprite *infoSprite = (CCSprite*)[buttonsBatchNode getChildByTag:kInfoSpriteTag];
        CCSprite *restoreSprite = (CCSprite*)[buttonsBatchNode getChildByTag:kRestorePurchaseSpriteTag];
        CCSprite *panelSprite = (CCSprite*)[buttonsBatchNode getChildByTag:kPanelSpriteTag];
        
        // Меняем z чтобы не накладывались кнопки подменю сверху на кнопку Опций при сворачивании.
        [self reorderChild:optionsMenu z:1];
        [buttonsBatchNode reorderChild:infoSprite z:0];
        [buttonsBatchNode reorderChild:restoreSprite z:0];
        CCCallFunc *removeMenuAction = [CCCallFunc actionWithTarget:self selector:@selector(removeOptionsMenu)];
        CCMoveTo *move1Action = [CCMoveTo actionWithDuration:0.2 position:optionsSprite.position];
        CCMoveTo *move2Action = [CCMoveTo actionWithDuration:0.3 position:optionsSprite.position];
        CCMoveTo *move3Action = [CCMoveTo actionWithDuration:0.4 position:optionsSprite.position];
        CCMoveTo *move4Action = [CCMoveTo actionWithDuration:0.5 position:optionsSprite.position];
        CCScaleTo *scaleAction = [CCScaleTo actionWithDuration:0.5 scaleX:0.1 scaleY:1];
        [panelSprite runAction:[CCSequence actions:scaleAction, removeMenuAction, nil]];
        [sfxToggle runAction:[CCSequence actions:move1Action, hideAction, nil]];
        [musicToggle runAction:[CCSequence actions:move2Action, hideAction, nil]];
        [infoSprite runAction:[CCSequence actions:move3Action, hideAction, nil]];
        [restoreSprite runAction:[CCSequence actions:move4Action, hideAction, nil]];
    }
    else 
    {
        // Make Sprites for Menu
        CCSprite *musicOnSpritePsd = [CCSprite spriteWithSpriteFrameName:@"button_music_on_pressed.png"];
        CCSprite *musicOffSpritePsd = [CCSprite spriteWithSpriteFrameName:@"button_music_off_pressed.png"];
        CCSprite *sfxOnSpritePsd = [CCSprite spriteWithSpriteFrameName:@"button_sfx_on_pressed.png"];
        CCSprite *sfxOffSpritePsd = [CCSprite spriteWithSpriteFrameName:@"button_sfx_off_pressed.png"];
        CCSprite *musicOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_on.png"];
        CCSprite *musicOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_off.png"];
        CCSprite *sfxOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_on.png"];
        CCSprite *sfxOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_off.png"];
        CCSprite *infoSprite = [CCSprite spriteWithSpriteFrameName:@"button_info.png"];
        CCSprite *restoreSprite = [CCSprite spriteWithSpriteFrameName:@"button_restore_purchase.png"];
        CCSprite *panelSprite = [CCSprite spriteWithSpriteFrameName:@"optionsButtonUnder.png"];
        
        // Adding sprites to Batchnode
        [buttonsBatchNode addChild:panelSprite z:1 tag:kPanelSpriteTag];
        [buttonsBatchNode addChild:infoSprite z:2 tag:kInfoSpriteTag];
        [buttonsBatchNode addChild:restoreSprite z:2 tag:kRestorePurchaseSpriteTag];
        
        // Options Menu Items
        CCMenuItemSprite *sfxOnButton = [CCMenuItemSprite itemWithNormalSprite:sfxOnSprite selectedSprite:sfxOnSpritePsd target:self selector:nil];
        CCMenuItemSprite *sfxOffButton = [CCMenuItemSprite itemWithNormalSprite:sfxOffSprite selectedSprite:sfxOffSpritePsd target:self selector:nil];
        CCMenuItemSprite *musicOnButton = [CCMenuItemSprite itemWithNormalSprite:musicOnSprite selectedSprite:musicOnSpritePsd target:self selector:nil];
        CCMenuItemSprite *musicOffButton = [CCMenuItemSprite itemWithNormalSprite:musicOffSprite selectedSprite:musicOffSpritePsd target:self selector:nil];
        CCMenuItemSpriteIndependent *infoButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:infoSprite selectedSprite:nil target:self selector:@selector(showCredits)];
        CCMenuItemSpriteIndependent *restoreButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:restoreSprite selectedSprite:nil target:self selector:@selector(restorePurchasePressed)];
        CCMenuItemToggle *musicToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicTogglePressed) items:musicOnButton, musicOffButton, nil];
        CCMenuItemToggle *sfxToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(SFXTogglePressed) items:sfxOnButton, sfxOffButton, nil];
        
        optionsMenu = [CCMenu menuWithItems:musicToggle, sfxToggle, infoButton, restoreButton, nil];
        [optionsMenu setPosition:ccp(0, 0)];
        [self addChild:optionsMenu z:6];
        
        // Hide and scale down sprites for Options Menu
        [panelSprite setAnchorPoint:ccp(0, 0.5)];
        [panelSprite setScaleX:0.1];
        [musicToggle setTag:kMusicToggleTag];
        [sfxToggle setTag:kSfxToggleTag];
        
        // Positioning sprites
        float xButtonPos = 0;
        float yButtonPos = 0;
        float padding;
        xButtonPos = optionsSprite.position.x;
        yButtonPos = optionsSprite.position.y;
        [panelSprite setPosition:ccp(xButtonPos, yButtonPos)];
        padding = infoSprite.contentSize.width;
        xButtonPos += padding*1.3;
        sfxToggle.position = ccp(xButtonPos, yButtonPos);
        xButtonPos += padding*1.1;
        yButtonPos += padding*0.2;
        musicToggle.position = ccp(xButtonPos, yButtonPos);
        xButtonPos += padding*1.1;
        yButtonPos -= padding*0.2;
        [infoSprite setPosition:ccp(xButtonPos, yButtonPos)];
        xButtonPos += padding*1.1;
//        yButtonPos += padding*0.2;
        [restoreSprite setPosition:ccp(xButtonPos, yButtonPos)];
        
        
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
        CCDelayTime *delay4Action = [CCDelayTime actionWithDuration:0.4];
        [panelSprite runAction:[CCScaleTo actionWithDuration:0.2 scaleX:1 scaleY:1]];
        [sfxToggle runAction:[CCSequence actions:hideAction, delay1Action ,showAction, nil]];
        [musicToggle runAction:[CCSequence actions:hideAction, delay2Action, showAction, nil]];
        [infoSprite runAction:[CCSequence actions:hideAction, delay3Action, showAction, nil]];
        [restoreSprite runAction:[CCSequence actions:hideAction, delay4Action, showAction, nil]];
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
    [optionsSprite setPosition:ccp(screenSize.width*0.63, screenSize.height*0.15)];
    [achievmentsSprite setPosition:ccp(screenSize.width*0.739, screenSize.height*0.352)];
    [playGameSprite setPosition:ccp(screenSize.width*0.8098, screenSize.height*0.5914)];
    [leaderboardSprite setPosition:ccp(screenSize.width*0.7098, screenSize.height*0.8078)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        achievmentsSprite.position = ccpAdd(achievmentsSprite.position, ccp(0,-32));
        playGameSprite.position = ccpAdd(playGameSprite.position, ccp(0,-64));
        leaderboardSprite.position = ccpAdd(leaderboardSprite.position, ccp(0,-64));
    }
    

    // Adding sprites to Batchnode
    [buttonsBatchNode addChild:playGameSprite z:3];
    [buttonsBatchNode addChild:optionsSprite z:3 tag:kOptionsSpriteTag];
    [buttonsBatchNode addChild:leaderboardSprite z:3];
    [buttonsBatchNode addChild:achievmentsSprite z:3];
    
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
    int num = 19;
    b2Vec2 verts[] = {
        b2Vec2(-270.8f / 64.0, 21.9f / 64.0),
        b2Vec2(-259.1f / 64.0, 50.4f / 64.0),
        b2Vec2(-226.0f / 64.0, 83.0f / 64.0),
        b2Vec2(-189.6f / 64.0, 87.4f / 64.0),
        b2Vec2(-155.3f / 64.0, 79.0f / 64.0),
        b2Vec2(-108.2f / 64.0, 96.2f / 64.0),
        b2Vec2(-81.2f / 64.0, 94.9f / 64.0),
        b2Vec2(-57.1f / 64.0, 87.0f / 64.0),
        b2Vec2(-39.5f / 64.0, 92.9f / 64.0),
        b2Vec2(9.9f / 64.0, 64.1f / 64.0),
        b2Vec2(20.6f / 64.0, 85.9f / 64.0),
        b2Vec2(54.3f / 64.0, 78.2f / 64.0),
        b2Vec2(94.9f / 64.0, 85.9f / 64.0),
        b2Vec2(139.6f / 64.0, 82.9f / 64.0),
        b2Vec2(164.3f / 64.0, 77.5f / 64.0),
        b2Vec2(192.2f / 64.0, 51.4f / 64.0),
        b2Vec2(222.5f / 64.0, 76.5f / 64.0),
        b2Vec2(255.4f / 64.0, 70.8f / 64.0),
        b2Vec2(275.0f / 64.0, 43.3f / 64.0)
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
//    CGPoint location = ccp(screenSize.width/4 + random() % (int)screenSize.width / 2, screenSize.height);
    CGPoint location = ccp(random() % (int)screenSize.width, screenSize.height);
    ChildCell *childCell = [[[ChildCell alloc] initWithWorld:world atLocation:location] autorelease];
    childCell.body->SetSleepingAllowed(YES);
    childCell.body->SetLinearDamping(0);
    [sceneSpriteBatchNode addChild:childCell z:1];
}

- (id)init {
    if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"food_bodies.plist"];
        
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        buttonsBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"buttons_sheet_1.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"buttons_sheet_1.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_levelselect.plist"];
        [self addChild:sceneSpriteBatchNode z:1];
        [self addChild:buttonsBatchNode z:5];
        
        // Background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"mainmenu_back.png"];
        [background setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
        [self addChild:background z:-1];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Logo
        CCSprite *genbyLogo = [CCSprite spriteWithSpriteFrameName:@"genby_logo.png"];
        genbyLogo.position = ccp(screenSize.width*0.4135, screenSize.height*0.5492);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            genbyLogo.position = ccpAdd(genbyLogo.position, ccp(0,-64));
        }
        [self addChild:genbyLogo z:5];
        
        // Add physics falling down food
        [self setupWorld];
        [self createGround:genbyLogo.position];
        [self scheduleUpdate];
        
        // Display Main Menu Buttons
        [self displayMainMenuButtons];
        
//        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_1];
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
    // Сбрасываем еду
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
    
    int32 velocityIterations = 5;
    int32 positionIterations = 2;
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
