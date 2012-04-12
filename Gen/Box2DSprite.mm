//
//  Box2DSprite.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@implementation Box2DSprite

@synthesize body;
@synthesize markedForDestruction;

- (void) setBodyShape:(NSString *)shapeName {
    
    // remove any existing fixtures from the body
    b2Fixture *fixture;
    while ((fixture = body->GetFixtureList()))
    {
        body->DestroyFixture(fixture);
    }
    
    // attach a new shape from the shape cache
    if (shapeName) {
        GB2ShapeCache *shapeCache = [GB2ShapeCache sharedShapeCache];
        [shapeCache addFixturesToBody:body forShapeName:shapeName];
        
        // Assign the shape's anchorPoint
        self.anchorPoint = [shapeCache anchorPointForShape:shapeName];
    }
}

- (id) initWithShape:(NSString *)shapeName inWorld:(b2World *)theWorld {
    
    NSAssert(theWorld != NULL, @"World is null!");
    NSAssert(shapeName != nil, @"Name is nil!");
        
    if ((self = [super init])) {
        world = theWorld;
        markedForDestruction = FALSE;
        
        // create the body
        b2BodyDef bodyDef;
        body = world->CreateBody(&bodyDef);
        
        // set the shape
        [self setBodyShape:shapeName];
    }
    return self;
}

- (void)createBodyAtLocation:(CGPoint)location
{
    
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    world = theWorld;
    markedForDestruction = FALSE;
    return self;
}

- (void) dealloc
{
    body->GetWorld()->DestroyBody(body);
    world = nil;
    body = nil;
    [super dealloc];
}

@end

