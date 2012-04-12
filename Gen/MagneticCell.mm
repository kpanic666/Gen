//
//  MagneticCell.m
//  Gen
//  Ловушка - отталкивает ChildCell от себя.
//  Created by Andrey Korikov on 02.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MagneticCell.h"
#import "Helper.h"

@interface MagneticCell ()
{
    NSMutableArray *cellsPosToDraw;
}

@end

@implementation MagneticCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    shape.m_radius = self.contentSize.width * 1.6f / PTM_RATIO;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = TRUE;
    fixtureDef.filter.categoryBits = kMagneticCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    for (Box2DSprite *spriteObj in listOfGameObjects) {
        // Притягиваем детей к self если у они в зоне действия магнита. Проверяет счетчик кол-ва действующих магнитов
        if (spriteObj.gameObjectType == kChildCellType && spriteObj.magneticCount > 0)
        {
            b2CircleShape magneticShape = *(b2CircleShape*) body->GetFixtureList()->GetShape();
            float magneticRadius = magneticShape.m_radius * PTM_RATIO;
            CGPoint distanceDiff = ccpSub(self.position, spriteObj.position);
            CGFloat lenght = ccpLength(distanceDiff);
            if (lenght < magneticRadius)
            {
                float atanFromDistance = atan2f(distanceDiff.y, distanceDiff.x);
                float xForce = (lenght - magneticRadius) * cosf(atanFromDistance) / PTM_RATIO * kMagneticPowerMultiplier;
                float yForce = (lenght - magneticRadius) * sinf(atanFromDistance) / PTM_RATIO * kMagneticPowerMultiplier;
                
                spriteObj.body->ApplyForceToCenter(b2Vec2 (xForce, yForce));
                
                // Добавляем координаты дочерней клетки для дальнейшей отрисовки линий
                [cellsPosToDraw addObject:NSStringFromCGPoint(spriteObj.position)];
            }
        }
    }
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        // Инициал. массив для хранения координат ChildCell к которым нужно нарисовать линию притяжения
        cellsPosToDraw = [[NSMutableArray alloc] init];
        
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"magneticcell_idle.png"]];
        gameObjectType = kEnemyTypeMagneticCell;
        characterState = kStateIdle;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)drawMagnetForces
{
    // Рисуем линий намагничивания от ChildCell к центру магнита
    for (NSString *posValue in cellsPosToDraw) 
    {
        CGPoint cellPos = CGPointFromString(posValue);
        
        CHECK_GL_ERROR_DEBUG();
        ccDrawColor4B(217, 166, 241, 255);
        glLineWidth(1.0f);
        ccDrawLine(self.position, cellPos);
    }
    [cellsPosToDraw removeAllObjects];
}

- (void)dealloc
{
    
    [cellsPosToDraw release];
    cellsPosToDraw = nil;
    
    [super dealloc];
}

@end