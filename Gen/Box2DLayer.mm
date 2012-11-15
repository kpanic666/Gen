//
//  Box2DLayer.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DLayer.h"
#import "Box2DSprite.h"
#import "GameManager.h"
#import "TestFlight.h"
#import "GameState.h"
#import "GCHelper.h"
#import "SimpleQueryCallback.h"
#import "HMVectorNode.h"
#import "TBXML.h"

static inline ccColor3B
ccc3FromUInt(const uint bytes)
{
	GLubyte r	= bytes >> 16 & 0xFF;
	GLubyte g	= bytes >> 8 & 0xFF;
	GLubyte b	= bytes & 0xFF;
    
	return ccc3(r, g, b);
}

@interface Box2DLayer()
{
    // Added for game stat and scores
    double levelStartTime;
    double levelRemainingTime;
}

@end

@implementation Box2DLayer

- (void)setupWorld
{
    b2Vec2 gravity;
    gravity.Set(0.0f, 0.0f);
    world = new b2World(gravity);
    
    // Add custom listener
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(TRUE);
	world->SetContinuousPhysics(TRUE);
}

- (void)setupDebugDraw
{
    m_debugDraw = new GLESDebugDraw(PTM_RATIO);
    world->SetDebugDraw(m_debugDraw);
    uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	flags += b2Draw::e_jointBit;
//    flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
}

- (void)createGround
{
    CGSize levelSize = [[GameManager sharedGameManager] getDimensionsOfCurrentScene];
    b2Vec2 lowerLeft = b2Vec2(0, 0);
    // Сдвигаем рамку земли в центр экрана если игра запущена на iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        lowerLeft += b2Vec2(kiPadScreenOffsetX / PTM_RATIO, kiPadScreenOffsetY / PTM_RATIO);
    }
    b2Vec2 lowerRight = lowerLeft + b2Vec2(levelSize.width/PTM_RATIO, 0);
    b2Vec2 upperRight = lowerRight + b2Vec2(0, levelSize.height/PTM_RATIO);
    b2Vec2 upperLeft = lowerLeft + b2Vec2(0, levelSize.height/PTM_RATIO);
    
    b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
    groundBodyDef.position.Set(0, 0);
    groundBody = world->CreateBody(&groundBodyDef);
    
    b2EdgeShape groundShape;
    
    // Bottom
    groundShape.Set(lowerLeft, lowerRight);
    groundBody->CreateFixture(&groundShape, 0);
    // Top
    groundShape.Set(upperLeft, upperRight);
    groundBody->CreateFixture(&groundShape, 0);
    // Left
    groundShape.Set(upperLeft, lowerLeft);
    groundBody->CreateFixture(&groundShape, 0);
    // Right
    groundShape.Set(upperRight, lowerRight);
    groundBody->CreateFixture(&groundShape, 0);
}

- (CCSprite*)createDecorWithSpriteFrameName:(NSString *)name location:(CGPoint)location
{
    CCSprite *decor = [CCSprite spriteWithSpriteFrameName:name];
    [decor setPosition:location];
    [decorsBatchNode addChild:decor];
    return decor;
}

- (ChildCell*)createChildCellAtLocation:(CGPoint)location
{
    ChildCell *childCell = [[[ChildCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:childCell z:2];
    [GameManager sharedGameManager].numOfTotalCells++;
    return childCell;
}

- (ExitCell*)createExitCellAtLocation:(CGPoint)location
{
    exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:exitCell z:1 tag:kExitCellSpriteTagValue];
    return exitCell;
}

- (BombCell*)createBombCellAtLocation:(CGPoint)location
{
    BombCell *bombCell = [[[BombCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:bombCell z:1];
    [GameManager sharedGameManager].numOfTotalCells++;
    return bombCell;
}

- (MagneticCell*)createMagneticCellAtLocation:(CGPoint)location
{
    MagneticCell *magneticCell = [[[MagneticCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:magneticCell z:-1];
    return magneticCell;
}

- (BubbleCell*)createBubbleCellAtLocation:(CGPoint)location
{
    BubbleCell *bubbleCell = [[[BubbleCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:bubbleCell z:2 tag:kBubbleCellTagValue];
    return bubbleCell;
}

- (MovingWall*)createMovingWallAtLocation:(CGPoint)location vertical:(BOOL)vertical
{
    MovingWall *movingWall = (MovingWall*)[MovingWall wallWithWorld:world location:location isVertical:vertical withGroundBody:groundBody];
    [sceneSpriteBatchNode addChild:movingWall z:1];
    return movingWall;
}

- (MovingWall*)createMovingWallAtLocation:(CGPoint)location vertical:(BOOL)vertical negOffset:(float32)negOffset posOffset:(float32)posOffset speed:(float32)speed
{
    MovingWall *movingWall = (MovingWall*)[MovingWall wallWithWorld:world location:location isVertical:vertical withGroundBody:groundBody negOffset:negOffset posOffset:posOffset speed:speed];
    [sceneSpriteBatchNode addChild:movingWall z:1];
    return movingWall;
}

- (GroundCell*)createGroundCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    GroundCell *groundCell = [GroundCell groundCellInWorld:theWorld position:pos name:name];
    [self addChild:groundCell z:-1];
//    [groundCell createParticles];
    return groundCell;
}

- (RedCell*)createRedCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    RedCell *redCell = [RedCell redCellInWorld:theWorld position:pos name:name];
    [self addChild:redCell z:-1];
    [redCell createParticles];
    return redCell;
}

- (RedCell*)createRedCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name withPinAtPos:(CGPoint)pinPos
{
    RedCell *redCell = [RedCell redCellInWorld:theWorld position:pos name:name withPinAtPos:pinPos];
    [self addChild:redCell z:-1];
    [sceneSpriteBatchNode addChild:redCell.pin];
    return redCell;
}

- (MetalCell*)createMetalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    MetalCell *metalCell = [MetalCell metalCellInWorld:theWorld position:pos name:name];
    [self addChild:metalCell z:-1];
    return metalCell;
}

- (MetalCell*)createMetalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name withPinAtPos:(CGPoint)pinPos
{
    MetalCell *metalCell = [MetalCell metalCellInWorld:theWorld position:pos name:name withPinAtPos:pinPos];
    [self addChild:metalCell z:-1];
    [sceneSpriteBatchNode addChild:metalCell.pin];
    return metalCell;
}

- (void)resetBubbleWithNode:(id)node
{
    CCSprite *bubble = (CCSprite*)node;
    [bubble stopAllActions];
    bubble.scale = 1;
    bubble.opacity = 255;
    
    // Set Random Position
    float xGravity = world->GetGravity().x;
    float xOffset = screenSize.width * 0.5 * xGravity;
    float yOffset = [bubble boundingBox].size.height * 0.5;
    float offScreenYPosition = screenSize.height + 1 + yOffset;
    int yPosition =  (yOffset * -1) - 1;
    int xPosition = random() % (int)(screenSize.width + ABS(xOffset));
    if (xOffset > 0) xPosition -= xOffset;
    [bubble setPosition:ccp(xPosition, yPosition)];
    
    // Set Horizontal Reflection (flipX)
    if ([bubble flipX]) {
        [bubble setFlipX:NO];
    }
    else {
        [bubble setFlipX:YES];
    }
    
    // Set Random texture
    int bubbleToDraw = random() % 4 + 1; // 1 to 4
    NSString *bubbleFileName = [NSString stringWithFormat:@"bubble%d.png",bubbleToDraw];
    [bubble setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:bubbleFileName]];
    
    // Actions
    xGravity = ABS(xGravity);
    if (xGravity < 1) {
        xGravity = 1;
    }
    float moveTime = 8 / xGravity;
    int opacityTime = random() % (2) + 1;
    // Set Random Delay Before Move up
    int moveDelay = random() % kMaxBubbleMoveDelay;
    if (moveDelay < kMinBubbleMoveDelay) {
        moveDelay = kMinBubbleMoveDelay;
    }
    
    // Scale up and down actions
    id scaleUp = [CCScaleTo actionWithDuration:1 scaleX:0.7 scaleY:1.3];
    id scaleDown = [CCScaleTo actionWithDuration:1 scaleX:1.2 scaleY:0.8];
    id scaleSeq = [CCSequence actions:scaleUp, scaleDown, nil];
    
    // Fade Out actions
    id opacityFade = [CCFadeOut actionWithDuration:opacityTime];
    id opacityFadeDelay = [CCDelayTime actionWithDuration:moveDelay+moveTime*0.7 ];
    id opacityFadeSeq = [CCSequence actionOne:opacityFadeDelay two:opacityFade];
    
    // Move from bottom to cover actions
    id moveAction = [CCMoveTo actionWithDuration:moveTime position:ccp([bubble position].x + xOffset, offScreenYPosition)];
    id moveDelayAction = [CCDelayTime actionWithDuration:moveDelay];
    
    // Reset actions. Reset all setting and reuse bubbles for next round up
    id resetAction = [CCCallFuncN actionWithTarget:self selector:@selector(resetBubbleWithNode:)];
    
    // Main sequence
    id waitMoveResetSeq = [CCSequence actions:moveDelayAction, moveAction, resetAction, nil];
    
    [bubble runAction:waitMoveResetSeq];
    [bubble runAction:[CCRepeatForever actionWithAction:scaleSeq]];
    [bubble runAction:opacityFadeSeq];
}

- (void)createBubble
{
    int bubbleToDraw = random() % 4 + 1; // 1 to 4
    NSString *bubbleFileName = [NSString stringWithFormat:@"bubble%d.png",bubbleToDraw];
    CCSprite *bubbleSprite = [CCSprite spriteWithSpriteFrameName:bubbleFileName];
    [sceneSpriteBatchNode addChild:bubbleSprite z:5];
    [self resetBubbleWithNode:bubbleSprite];
}

#pragma mark -
#pragma mark Water and Waves

- (void)resetBlickWithNode:(id)node
{
    CCSprite *blick = (CCSprite*)node;
    
    // Set Random Position
    int xPosition = random() % (int)(screenSize.width / 32);
    [blick setPosition:ccp(xPosition * 32, screenSize.height)];
    
    // Set Random texture
    int blickToDraw = random() % 2 + 1; // 1 to 2
    NSString *blickFileName = [NSString stringWithFormat:@"water_blick%d.png",blickToDraw];
    [blick setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:blickFileName]];
    
    // Actions
    // Set Random Delay Before Fade in
    int startDelay = random() % kMaxBubbleMoveDelay;
    if (startDelay < kMinBubbleMoveDelay) {
        startDelay = kMinBubbleMoveDelay;
    }
    
    // Reset action. Reset all setting and reuse blicks for next round up
    id resetAction = [CCCallFuncN actionWithTarget:self selector:@selector(resetBlickWithNode:)];
    
    // Fade actions
    id fadeStartPause = [CCDelayTime actionWithDuration:startDelay];
    id fadeInAction = [CCFadeIn actionWithDuration:1];
    id fadeMiddleStatePause = [CCDelayTime actionWithDuration:0.5];
    id fadeOutAction = [CCFadeOut actionWithDuration:0.5];
    id fadeSeq = [CCSequence actions:fadeStartPause, fadeInAction, fadeMiddleStatePause, fadeOutAction, resetAction, nil];
    
    [blick runAction:fadeSeq];
}

- (void)createWaterBlick
{
    int blickToDraw = random() % 2 + 1; // 1 to 2
    NSString *blickFileName = [NSString stringWithFormat:@"water_blick%d.png",blickToDraw];
    CCSprite *blickSprite = [CCSprite spriteWithSpriteFrameName:blickFileName];
    [blickSprite setAnchorPoint:ccp(0.5, 1)];
    [blickSprite setOpacity:0];
    [waterBatchNode addChild:blickSprite z:1];
    [self resetBlickWithNode:blickSprite];
}

- (void)createWater
{
    CCSprite *bottomSprite = [CCSprite spriteWithSpriteFrameName:@"water_bottom.png"];
    CCSprite *topSprite = [CCSprite spriteWithSpriteFrameName:@"water_top.png"];
    CCSprite *surfForegroundSprite = [CCSprite spriteWithSpriteFrameName:@"water_surf_foreground.png"];
    CCSprite *surfBackgroundSprite = [CCSprite spriteWithSpriteFrameName:@"water_surf_background.png"];
    int numOfBottomTiles = screenSize.width / bottomSprite.contentSize.width;
    int numOfTopTiles = screenSize.width / topSprite.contentSize.width;
    int numOfForegroundTiles = screenSize.width / surfForegroundSprite.contentSize.width + 2;
    int numOfBackgroundTiles = screenSize.width / surfBackgroundSprite.contentSize.width + 2;
    
    // Start to fill all bottom and top side of the screen with water sprites
    for (int x = 0; x <= numOfBottomTiles; x++) {
        CCSprite *waterSprite = [CCSprite spriteWithSpriteFrameName:@"water_bottom.png"];
        [waterSprite setAnchorPoint:ccp(0, 0)];
        [waterSprite setPosition:ccp(x * waterSprite.contentSize.width, 0)];
        [waterBatchNode addChild:waterSprite z:0];
    }
    for (int x = 0; x <= numOfTopTiles; x++) {
        CCSprite *waterSprite = [CCSprite spriteWithSpriteFrameName:@"water_top.png"];
        [waterSprite setAnchorPoint:ccp(0, 1)];
        [waterSprite setPosition:ccp(x * waterSprite.contentSize.width, screenSize.height)];
        [waterBatchNode addChild:waterSprite z:0];
    }
    
    // Add waves at the top of the stage
    for (int x = -1; x < numOfBackgroundTiles; x++) {
        CCSprite *waterSprite = [CCSprite spriteWithSpriteFrameName:@"water_surf_background.png"];
        [waterSprite setAnchorPoint:ccp(0, 1)];
        [waterSprite setPosition:ccp(x * waterSprite.contentSize.width, screenSize.height)];
        [waterBatchNode addChild:waterSprite z:2 tag:kWaterWaveBackgroundTag];
        if (x == numOfBackgroundTiles-1) rightmostXPosOfWave = waterSprite.position.x;
    }
    for (int x = -1; x < numOfForegroundTiles; x++) {
        CCSprite *waterSprite = [CCSprite spriteWithSpriteFrameName:@"water_surf_foreground.png"];
        [waterSprite setAnchorPoint:ccp(0, 1)];
        [waterSprite setPosition:ccp(x * waterSprite.contentSize.width, screenSize.height)];
        [waterBatchNode addChild:waterSprite z:3 tag:kWaterWaveForegroundTag];
        if (x == -1) leftmostXPosOfWave = waterSprite.position.x;
    }
}

- (void)updateWater:(ccTime)dt
{
    float dX = kWaterWavesPPS * dt;
    leftmostXPosOfWave += dX;
    rightmostXPosOfWave -= dX;
    
    // False - to the left, True - to the right
    for (CCSprite *tempSprite in [waterBatchNode children])
    {
        if (tempSprite.tag == kWaterWaveBackgroundTag)
        {
            [self moveWaterWithSprite:tempSprite andDirection:false dX:dX];
        }
        else if (tempSprite.tag == kWaterWaveForegroundTag)
        {
            [self moveWaterWithSprite:tempSprite andDirection:true dX:dX];
        }
    }
}

- (void)moveWaterWithSprite:(CCSprite*)sprite andDirection:(BOOL)toRight dX:(float)dX
{
    if (toRight == TRUE) {
        if (sprite.position.x >= screenSize.width) {
            sprite.position = ccp(leftmostXPosOfWave - sprite.contentSize.width, sprite.position.y);
            leftmostXPosOfWave = sprite.position.x;
        }
        else
        {
            sprite.position = ccp(sprite.position.x + dX, sprite.position.y);
        }
    }
    else
    {
        if (sprite.position.x <= -1 * sprite.contentSize.width) {
            sprite.position = ccp(rightmostXPosOfWave + sprite.contentSize.width, sprite.position.y);
            rightmostXPosOfWave = sprite.position.x;
        }
        else
        {
            sprite.position = ccp(sprite.position.x - dX, sprite.position.y);
        }
    }
}

- (void)setFlowing:(b2Vec2)flowingCurse
{
    world->SetGravity(flowingCurse);
    
    // Create additional water bubbles, because area of flowing is growing up now
    int nBubblesToAdd = ABS(flowingCurse.x) * kMaxNumOfBubbleOnScene / 2;
    for (int x = 0; x < nBubblesToAdd; x++) {
        [self createBubble];
    }
    
    // Change particle system properties
    [psPlankton setGravity:ccp(50*flowingCurse.x, [psPlankton gravity].y)];
}

- (void)displayLevelName
{
    [uiLayer displayText:[NSString stringWithFormat:@"Level %@", [GameManager sharedGameManager].levelName]];
}

- (BOOL)loadLevelMapFromXML
{
    // Загружаем XML из локальной сборки, если не найден, то проверяем на сервере в интернете
    NSError *error;
    TBXML *xml;
    
    // 1. Load XML from local build
    xml = [[[TBXML alloc] initWithXMLFile:[GameManager sharedGameManager].levelName fileExtension:@"xml" error:&error] autorelease];
    if (error) {
        CCLOG(@"TBXML Error-Failed to open local file:%@ %@", [error localizedDescription], [error userInfo]);
    }
    else
    {
        CCLOG(@"TBXML Loaded local file - %@", [TBXML elementName:xml.rootXMLElement]);
        // If TBXML found a root node, process element and iterate all children
        if (xml.rootXMLElement)
        {
            [self traverseLevelMapElements:xml.rootXMLElement];
            return true;
        }
        else
        {
            CCLOG(@"TBXML local file incorrect");
            return false;
        }
    }
    
    // 2. If nothing found on local disk, than Load XML from network
    // Create a success block to be called when the asyn request completes
//    NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.1/%@.xml",[GameManager sharedGameManager].levelName];
    NSString *urlString = [NSString stringWithFormat:@"http://127.0.0.1/%@.xml",[GameManager sharedGameManager].levelName];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *xmlData = [[NSData alloc] initWithContentsOfURL:url];
    TBXML *xmlInet = [[TBXML alloc] initWithXMLData:xmlData error:&error];
    
    if (error) {
        CCLOG(@"TBXML Error-Failed to open XML from Network:%@ %@", [error localizedDescription], [error userInfo]);
        return false;
    }
    else
    {
        CCLOG(@"TBXML Loaded XML from Network");
        // If TBXML found a root node, process element and iterate all children
        if ([[TBXML elementName:xmlInet.rootXMLElement] isEqualToString:@"map"])
        {
            [self traverseLevelMapElements:xmlInet.rootXMLElement];
        }
        else
        {
            CCLOG(@"TBXML XML from Network has incorrect content");
            return false;
        }
    }
    
    [xmlData release];
    [xmlInet release];
    
    return true;
}

#pragma mark -
#pragma mark XML Level Parser

- (void)traverseLevelMapElements:(TBXMLElement*)element
{
    // Имена атрибутов
    NSString *attribNames[] = {
        @"x",
        @"y",
        @"rotation",
        @"scaleX",
        @"scaleY",
        @"tintMultiplier",
        @"alpha",
        @"tintColor",
        @"flipX",
        @"flipY"
    };

    do {
        // Obtain first attribute from element
        TBXMLAttribute * attribute = element->firstAttribute;
        
        // if attribute is valid
        if (attribute)
        {
            // Variable
            float cX,cY;
            NSString *elementName = [TBXML elementName:element];

            
            cX = [[TBXML valueOfAttributeNamed:attribNames[0] forElement:element] floatValue];
            cY = [[TBXML valueOfAttributeNamed:attribNames[1] forElement:element] floatValue];
            CGPoint cellPos = [Helper convertPosition:ccp(cX, cY)];
            
            if ([elementName isEqualToString:@"ChildCell"]) {
                [self createChildCellAtLocation:cellPos];
            }
            else if ([elementName isEqualToString:@"ExitCell"])
            {
                [self createExitCellAtLocation:cellPos];
            }
            else if ([elementName isEqualToString:@"BubbleCell"])
            {
                [self createBubbleCellAtLocation:cellPos];
            }
            else if ([elementName isEqualToString:@"MagneticCell"])
            {
                [self createMagneticCellAtLocation:cellPos];
            }
            else if ([elementName isEqualToString:@"BombCell"])
            {
                [self createBombCellAtLocation:cellPos];
            }
            else if ([[elementName substringToIndex:6] isEqualToString:@"ground"])
            {
                [self createGroundCellInWorld:world position:cellPos name:elementName];
            }
            else if ([[elementName substringToIndex:3] isEqualToString:@"red"])
            {
                [self createRedCellInWorld:world position:cellPos name:elementName];
            }
            else if ([[elementName substringToIndex:5] isEqualToString:@"metal"])
            {
                [self createMetalCellInWorld:world position:cellPos name:elementName];
            }
            else if ([[elementName substringToIndex:4] isEqualToString:@"dec_"])
            {
                NSString *attribValue;
                CCSprite *cSprite = [self createDecorWithSpriteFrameName:[elementName stringByAppendingString:@".png"] location:cellPos];

                for (int i = 2; i < 10; i++) {
                    attribValue = [TBXML valueOfAttributeNamed:attribNames[i] forElement:element];
                    if (attribValue == NULL) {
                        continue;
                    }
                    
                    switch (i) {
                        // Rotation
                        case 2:
                            [cSprite setRotation:[attribValue floatValue]];
                            break;
                        // ScaleX
                        case 3:
                            [cSprite setScaleX:[attribValue floatValue]];
                            break;
                        // ScaleY
                        case 4:
                            [cSprite setScaleY:[attribValue floatValue]];
                            break;
                        // TintMultiplier - 5 Alpha - 6
                        case 5 ... 6:
                            [cSprite setOpacity:255 * [attribValue floatValue]];
                            break;
                        // Tint
                        case 7:
                        {
                            [cSprite setColor:ccc3FromUInt([attribValue intValue])];
                            break;
                        }
                        // FlipX
                        case 8:
                            [cSprite setFlipX:[attribValue boolValue]];
                            break;
                        // FlipY
                        case 9:
                            [cSprite setFlipY:[attribValue boolValue]];
                            break;
                            
                        default:
                            break;
                    }
                }
            }
            else if ([elementName isEqualToString:@"Settings"])
            {
                int i = [[TBXML valueOfAttributeNamed:@"maxCellsCount" forElement:element] intValue];
                [[GameManager sharedGameManager] setNumOfMaxCells:i];
                i = [[TBXML valueOfAttributeNamed:@"needCellsCount" forElement:element] intValue];
                [[GameManager sharedGameManager] setNumOfNeededCells:i];
            }
        }
        
        // if the element has child elements, process them
        if (element->firstChild)
            [self traverseLevelMapElements:element->firstChild];
        
        // Obtain next sibling element
    } while ((element = element->nextSibling));
}

- (id)init
{
    if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        
        // enable events
        self.isTouchEnabled = YES;
        self.tag = kBox2DLayer;
        gameOver = false;
        
        // seed randomizer
        srandom(time(NULL));
        
        bodiesToDestroy = [[NSMutableArray alloc] init];
        
        // Обнуляем переменные для статистики и счета
        levelStartTime = CACurrentMediaTime();
        levelRemainingTime = 0;
        
        [self setupWorld];
        [self createGround];
#if DEBUG_DRAW
        [self setupDebugDraw];
#endif
        // load physics definitions
        NSString *sceneBodiesFileName = [NSString stringWithFormat:@"scene%@bodies.plist", [[GameManager sharedGameManager].levelName substringFromIndex:2]];
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:sceneBodiesFileName];
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"food_bodies.plist"];
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz" capacity:40];
        decorsBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"ingame_decors.pvr.ccz"];
        waterBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"water_tiles.pvr.ccz" capacity:98];
        superpowerBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"superpower.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ingame_decors.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"water_tiles.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"superpower.plist"];
        [self addChild:decorsBatchNode z:-2];
        [self addChild:sceneSpriteBatchNode z:1 tag:kMainSpriteBatchNode];
        [self addChild:superpowerBatchNode z:2];
        [self addChild:waterBatchNode z:3];
        
        // Add animation cache
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"genby_anim.plist"];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100) batchNodeForPower:superpowerBatchNode] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // Draw Node for drawing DisJoints, ParentCell Radius, Magnetic Forces
        HMVectorNode *drawNode = [[HMVectorNode alloc] init];
        [self addChild:drawNode z:0 tag:kDrawNodeTagValue];
        [drawNode release];
        
        [self loadLevelMapFromXML];
        
        // Create water bubbles
        for (int x = 0; x < kMaxNumOfBubbleOnScene; x++) {
            [self createBubble];
        }
        
        // Create water blicks
        for (int x = 0; x < kMaxNumOfBubbleOnScene; x++) {
            [self createWaterBlick];
        }
        [self createWater];
        
        [self scheduleUpdate];
        
        // Create plankton particles
        psPlankton = [CCParticleSystemQuad particleWithFile:@"ps_plankton.plist"];
        [self addChild:psPlankton z:-3];
//        psPlankton.position = ccp(screenSize.width * 0.5, screenSize.height);
    
        // Фиксируем прогресс пройденных уровней. Пройдя уровень сравниваем со значением макс доступного и если меньше то увеличиваем на один
        int levelNum = (int)[GameManager sharedGameManager].curLevel - 100;
        if ([GameState sharedInstance].highestOpenedLevel < levelNum)
        {
            [GameState sharedInstance].highestOpenedLevel++;
            [[GameState sharedInstance] save];
        }
        
        // Display level name with delay
        [self scheduleOnce:@selector(displayLevelName) delay:0.4];
    }
    return self;
}

-(void) dealloc
{
    delete contactListener;
    contactListener = NULL;
    [bodiesToDestroy release];
    bodiesToDestroy = nil;
    exitCell = nil;
    parentCell = nil;
    if (world) {
        delete world;
        world = NULL;
    }
    if (m_debugDraw) {
        delete m_debugDraw;
        m_debugDraw = nil;
    }
    
    [super dealloc];
}

- (void)draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
    //
	[super draw];
    
    // Reset DrawNode canvas
    HMVectorNode *drawNode = (HMVectorNode*)[self getChildByTag:kDrawNodeTagValue];
    [drawNode clear];
    
    // Draw lines for distance joints between ChildCell and ParentCell
    [parentCell drawDisJoints];

    // Рисуем линии от магнитов к ChildCells
    for (CCSprite *tempSprite in [sceneSpriteBatchNode children])
    {
        if ([tempSprite isKindOfClass:[MagneticCell class]])
        {
            MagneticCell *magneticCell = (MagneticCell*)tempSprite;
            [magneticCell drawMagnetForces];
        }
    }

#if DEBUG_DRAW	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
#endif
}

- (void)displayGameOverLayer
{
    [uiLayer hideUI];
    ccColor4B c = ccc4(0, 0, 0, 0); // Black transparent background
    CompleteLevelLayer *gameOverLayer = [[[CompleteLevelLayer alloc] initWithColor:c] autorelease];
    [self addChild:gameOverLayer z:10 tag:kGameOverLayer];
    // Останавливаем всю анимацию и жизнь в фоне
    [self setIsTouchEnabled:NO];
    [self pauseSchedulerAndActions];
    for (CCNode *tempNode in [sceneSpriteBatchNode children]) {
        [tempNode pauseSchedulerAndActions];
    }
}

- (void)showTipsElement:(CCNode*)element delay:(float)delay
{
    [element runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay], [CCFadeIn actionWithDuration:1], nil]];
}

- (void)hideTipsElement:(CCNode*)element delay:(float)delay
{
    [element runAction:[CCSequence actions:
                        [CCDelayTime actionWithDuration:delay],
                        [CCFadeOut actionWithDuration:1],
                        [CCCallBlockN actionWithBlock:
                         ^(CCNode *node){
                             [node removeFromParentAndCleanup:YES];
                         }],
                        nil]];
}

- (void)calcScore
{
    GameManager *gameManager = [GameManager sharedGameManager];
    gameManager.levelElapsedTime = CACurrentMediaTime() - levelStartTime;
    levelRemainingTime = kLevelMaxTime - gameManager.levelElapsedTime;
    
    // Проверяем оставшееся время. может быть отрицательным если игрок сильно замешкался, то ставим в 0
    levelRemainingTime = MAX(0, levelRemainingTime);
    // Насчитываем очки за оставшееся время
    gameManager.levelTotalScore += levelRemainingTime * kRemainingTimeMulti;
    // Насчитываем очки за кол-во спасенных ячеек
    gameManager.levelTotalScore += gameManager.numOfNeededCells * kGoalCellsMulti;
    gameManager.levelTotalScore += (gameManager.numOfSavedCells - gameManager.numOfNeededCells) * kExtraCellsMulti;
    // Насчитываем очки за набранные звезды. 1 звезда - Collected == Needed, 2 - Collected > Needed < Max, 3 - Coll=Max
    if (gameManager.numOfSavedCells == gameManager.numOfNeededCells) {
        gameManager.levelStarsNum = 1;
    }
    if (gameManager.numOfSavedCells > gameManager.numOfNeededCells && gameManager.numOfSavedCells < gameManager.numOfMaxCells)
    {
        gameManager.levelStarsNum = 2;
    }
    if (gameManager.numOfSavedCells == gameManager.numOfMaxCells) {
        gameManager.levelStarsNum = 3;
    }
    gameManager.levelTotalScore += gameManager.levelStarsNum * kStarAchievedMulti;
    // Насчитываем очки за кол-во нажатий на игровое поле при прохождении уровня. За каждое нажатие вычитаем очки
    gameManager.levelTotalScore += gameManager.levelTappedNum * kTapMulti;
    // Проверяем на положительность
    gameManager.levelTotalScore = MAX(0, gameManager.levelTotalScore);
}

#pragma mark -
#pragma mark Bubble Tap Check
- (BOOL)bubbleTapCheckAtLoc:(b2Vec2)locationWorld
{
    b2AABB aabb;
    b2Vec2 delta = b2Vec2(1.0/PTM_RATIO, 1.0/PTM_RATIO);
    aabb.lowerBound = locationWorld - delta;
    aabb.upperBound = locationWorld + delta;
    SimpleQueryCallback callback(locationWorld, nil, kEnemyTypeBubble);
    world->QueryAABB(&callback, aabb);
    
    if (callback.fixtureFound)
    {
        b2Body *foundBody = callback.fixtureFound->GetBody();
        Box2DSprite *foundSprite = (Box2DSprite*) foundBody->GetUserData();
        if (foundSprite.characterState == kStateTraveling) {
            [foundSprite changeState:kStateTakingDamage];
            return true;
        }
    }
    return false;
}

#pragma mark -
#pragma mark Achievements checking
- (void)checkAchievements
{
    GameManager *gameManager = [GameManager sharedGameManager];
    GameState *gameState = [GameState sharedInstance];
    
    // Check Complete level 10
    if (!gameState.completedLevel10) {
        if (gameManager.curLevel == kGameLevel10 && gameManager.hasLevelWin) {
            gameState.completedLevel10 = true;
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel10 percentComplete:100.0];
        }
    }
    // Check Complete level 20
    if (!gameState.completedLevel20) {
        if (gameManager.curLevel == kGameLevel20 && gameManager.hasLevelWin) {
            gameState.completedLevel20 = true;
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel20 percentComplete:100.0];
        }
    }
    if (!gameState.completedLevel30) {
        if (gameManager.curLevel == kGameLevel30 && gameManager.hasLevelWin) {
            gameState.completedLevel30 = true;
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel30 percentComplete:100.0];
        }
    }
    if (!gameState.completedLevel40) {
        if (gameManager.curLevel == kGameLevel40 && gameManager.hasLevelWin) {
            gameState.completedLevel40 = true;
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel40 percentComplete:100.0];
        }
    }
    
    // Check First Fail, Unwary, Destroyer (1, 50, 100 spoiled food)
    if (gameState.cellsKilled > 0 && gameState.cellsKilled <= kAchievementCellDestroyerNum)
    {
        float pctComplete;
        
        if (gameState.cellsKilled < kAchievementFirstFailNum) {
            pctComplete = MIN(((float)gameState.cellsKilled / (int)kAchievementFirstFailNum) * 100.0, 100);
            [[GCHelper sharedInstance] reportAchievement:kAchievementFirstFail percentComplete:pctComplete];
            pctComplete = MIN(((float)gameState.cellsKilled / (int)kAchievementUnwaryNum) * 100.0, 100);
            [[GCHelper sharedInstance] reportAchievement:kAchievementUnwary percentComplete:pctComplete];
            pctComplete = MIN(((float)gameState.cellsKilled / (int)kAchievementCellDestroyerNum) * 100.0, 100);
            [[GCHelper sharedInstance] reportAchievement:kAchievementCellDestroyer percentComplete:pctComplete];
        }
        else if (gameState.cellsKilled < kAchievementUnwaryNum)
        {
            if (!gameState.completedFirstFail) {
                gameState.completedFirstFail = true;
                pctComplete = MIN(((float)gameState.cellsKilled / (int)kAchievementFirstFailNum) * 100.0, 100);
                [[GCHelper sharedInstance] reportAchievement:kAchievementFirstFail percentComplete:pctComplete];
            }
            pctComplete = MIN(((float)gameState.cellsKilled / (int)kAchievementUnwaryNum) * 100.0, 100);
            [[GCHelper sharedInstance] reportAchievement:kAchievementUnwary percentComplete:pctComplete];
            pctComplete = MIN(((float)gameState.cellsKilled / (int)kAchievementCellDestroyerNum) * 100.0, 100);
            [[GCHelper sharedInstance] reportAchievement:kAchievementCellDestroyer percentComplete:pctComplete];
        }
        else if (gameState.cellsKilled < kAchievementCellDestroyerNum)
        {
            if (!gameState.completedUnwary) {
                gameState.completedUnwary = true;
                pctComplete = MIN(((float)gameState.cellsKilled / (int)kAchievementUnwaryNum) * 100.0, 100);
                [[GCHelper sharedInstance] reportAchievement:kAchievementUnwary percentComplete:pctComplete];
            }
            pctComplete = ((float)gameState.cellsKilled / (int)kAchievementCellDestroyerNum) * 100.0;
            [[GCHelper sharedInstance] reportAchievement:kAchievementCellDestroyer percentComplete:pctComplete];
        }
        else
        {
            pctComplete = ((float)gameState.cellsKilled / (int)kAchievementCellDestroyerNum) * 100.0;
            [[GCHelper sharedInstance] reportAchievement:kAchievementCellDestroyer percentComplete:pctComplete];
            // Прекращает подсчитывать кол-во уничтоженной еды после получения макс ачивки
            if (gameState.cellsKilled >= kAchievementCellDestroyerNum) {
                gameState.cellsKilled++;
            }
        }
    }
    
    [gameState save];
}

- (void)updateGameStatsAndProgress
{
    GameManager *gameManager = [GameManager sharedGameManager];
    GameState *gameState = [GameState sharedInstance];
    int levelNum = (int)gameManager.curLevel - 100;
    
    // Фиксируем прогресс пройденных уровней. Пройдя уровень сравниваем со значением макс доступного и если меньше то увеличиваем на один
    if ([GameState sharedInstance].highestOpenedLevel == levelNum) [GameState sharedInstance].highestOpenedLevel++;
    
    // Запоминаем кол-во набранных звезд если их больше чем было
    if (gameManager.levelStarsNum > [[gameState.levelHighestStarsNumArray objectAtIndex:levelNum-1] integerValue]) {
        [[gameState levelHighestStarsNumArray] replaceObjectAtIndex:levelNum-1 withObject:[NSNumber numberWithInt:gameManager.levelStarsNum]];
    }
    
    // Запоминаем High Score для уровня и докладываем в GameCenter если значение изменилось
    if (gameManager.levelTotalScore > [[gameState.levelHighestScoreArray objectAtIndex:levelNum-1] integerValue])
    {
        [[gameState levelHighestScoreArray] replaceObjectAtIndex:levelNum-1 withObject:[NSNumber numberWithInt:gameManager.levelTotalScore]];
        [gameManager setLevelHighScoreAchieved:YES];
        
        // Доложить Score в GameCenter
        unsigned int summaryScore = 0;
        for (int i=0; i < [gameState.levelHighestScoreArray count]; i++) {
            summaryScore += [[gameState.levelHighestScoreArray objectAtIndex:i] integerValue];
        }
        [[GCHelper sharedInstance] reportScore:kLeaderboardChapter1 score:summaryScore];
    }
    
    [gameState save];
}

#pragma mark Update

- (void)update:(ccTime)dt
{
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
    for (b2Body *b = world->GetBodyList(); b != NULL; b = b->GetNext())
    {
        if (b->GetUserData() != NULL)
        {
            Box2DSprite *sprite = (Box2DSprite*) b->GetUserData();
            if (sprite != 0) {
                sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                sprite.rotation = CC_RADIANS_TO_DEGREES(b->GetAngle() * -1);
                // Mark body for delete
                if (sprite.markedForDestruction) {
                    [self markBodyForDestruction:sprite];
                }
            }
        }
    }
    
    // Уничтожаем тела клеток попавших в опасность или в выход
    [self destroyBodies];
    
    // Обновляем состояние всех членов spritebatchnode
    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    for (CCSprite *tempSprite in listOfGameObjects)
    {
        if ([tempSprite isKindOfClass:[GameCharacter class]])
        {
            GameCharacter *tempChar = (GameCharacter*)tempSprite;
            // Заставляем осьминожку грустить если еда пропадает
            if (tempChar.gameObjectType == kChildCellType && tempChar.characterState == kStateDead) {
                [exitCell changeState:kStateSad];
            }
            [tempChar updateStateWithDeltaTime:dt andListOfGameObjects:listOfGameObjects];
            
        }
    }
    
    // Двигаем водные волны
    [self updateWater:dt];
    
    // Обновляем счетчик UI, если это нужно
    GameManager *gameManager = [GameManager sharedGameManager];
    if (gameManager.needToUpdateScore) {
        [uiLayer updateScore];
    }
    
    // Проверяем выигрыш или проигрыш
    if (!gameOver)
    {
        // Если не осталось свободноплавающих ячеек и спасено нужно количество то ВЫИГРЫШ
        if (gameManager.numOfTotalCells == 0 && gameManager.numOfSavedCells >= gameManager.numOfNeededCells)
        {
            gameOver = true;
            [gameManager setHasLevelWin:YES];
            [self calcScore];
            [self checkAchievements];
            [self updateGameStatsAndProgress];
            [self scheduleOnce:@selector(displayGameOverLayer) delay:1.5];
        }
        else if (gameManager.numOfTotalCells == 0 && gameManager.numOfSavedCells < gameManager.numOfNeededCells)
        {
            gameOver = true;
            [self checkAchievements];
            [self scheduleOnce:@selector(displayGameOverLayer) delay:1.5];
        }
    }
}

- (void)markBodyForDestruction:(Box2DSprite *)obj
{
    [bodiesToDestroy addObject:[NSValue valueWithPointer:obj]];
}

- (void)destroyBodies
{
    for (NSValue *value in bodiesToDestroy) {
        Box2DSprite *obj = (Box2DSprite*)[value pointerValue];
        if (obj && obj.body && obj.markedForDestruction) {
            obj.body->SetTransform(b2Vec2(0,0), 0);
            world->DestroyBody(obj.body);
            obj.body = nil;
        }
    }
    [bodiesToDestroy removeAllObjects];
}

#pragma mark Touch Events

- (void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    // Проверяем попали мы по пузырю или нет. Если да, то лопаем его и освобождаем ячейку
    if ([sceneSpriteBatchNode getChildByTag:kBubbleCellTagValue]) {
        if ([self bubbleTapCheckAtLoc:locationWorld])
        {
            return TRUE;
        }
    }
    
    // Отображаем главную ячейку под пальцем игрока и она начинает притягивать
    [parentCell changeBodyPosition:locationWorld];
    [parentCell changeState:kStateTraveling];
    
    // Увеличиваем счетчик нажатий на экран
    [GameManager sharedGameManager].levelTappedNum++;

    return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    if ([parentCell characterState] == kStateTraveling) {
        [parentCell changeBodyPosition:locationWorld];
    }    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{    
    // Прячем главную клетку и перестаем притягивать
    [parentCell changeState:kStateIdle];
}


- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    return self;
}

@end
