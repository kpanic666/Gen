//
//  Box2DLayer.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DLayer.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"
#import "Box2DSprite.h"

@implementation Box2DLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    
    // add Gameplay layer for Maincharacter, enemies, background. 
    Box2DLayer *layer = [self node];
    [scene addChild:layer z:0];
    
    return scene;
}

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
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    b2Vec2 lowerLeft = b2Vec2(0, 0);
    b2Vec2 lowerRight = b2Vec2(screenSize.width/PTM_RATIO, 0);
    b2Vec2 upperRight = b2Vec2(screenSize.width/PTM_RATIO, screenSize.height/PTM_RATIO);
    b2Vec2 upperLeft = b2Vec2(0, screenSize.height/PTM_RATIO);
    
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

- (id)init
{
    if ((self = [super init])) {
        
        // enable events
        self.isTouchEnabled = YES;
        // seed randomizer
        srandom(time(NULL));
        
        bodiesToDestroy = [[NSMutableArray alloc] init];
        
        [self setupWorld];
        [self createGround];
#if DEBUG_DRAW
        [self setupDebugDraw];
#endif
        [self scheduleUpdate];
    }
    return self;
}

-(void) dealloc
{
    delete contactListener;
    contactListener = NULL;
    
    [bodiesToDestroy release];
    bodiesToDestroy = nil;
    
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
    
#if DEBUG_DRAW	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
#endif
}

- (void)update:(ccTime)dt
{
	// Fixed Time Step
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
            // Mark body for delete
            if (sprite.markedForDestruction) {
                [self markBodyForDestruction:sprite];
            }
        }
    }
    
    // Уничтожаем тела клеток попавших в опасность или в выход
    [self destroyBodies];
    
    // Force update all objects
    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    for (GameCharacter *tempChar in listOfGameObjects) {
        [tempChar updateStateWithDeltaTime:dt andListOfGameObjects:listOfGameObjects];
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

@end
