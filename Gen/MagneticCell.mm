//
//  MagneticCell.m
//  Gen
//  Ловушка - отталкивает ChildCell от себя.
//  Created by Andrey Korikov on 02.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MagneticCell.h"
#import "Helper.h"
#import "HMVectorNode.h"

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
    shape.m_radius = self.contentSize.width * 1.06 / PTM_RATIO;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = TRUE;
    fixtureDef.filter.categoryBits = kMagneticCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    for (CCSprite *tempSprite in listOfGameObjects)
    {
        if ([tempSprite isKindOfClass:[Box2DSprite class]])
        {
            Box2DSprite *spriteObj = (Box2DSprite*)tempSprite;
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
                    float xForce = (lenght - magneticRadius) * cosf(atanFromDistance) * kMagneticPowerMultiplier;
                    float yForce = (lenght - magneticRadius) * sinf(atanFromDistance) * kMagneticPowerMultiplier;
                    b2Vec2 forcePower = b2Vec2 (xForce / PTM_RATIO, yForce / PTM_RATIO);
                    spriteObj.body->ApplyForceToCenter(forcePower);
                    
                    // Добавляем координаты дочерней клетки для дальнейшей отрисовки линий
                    [cellsPosToDraw addObject:NSStringFromCGPoint(spriteObj.position)];
                }
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
        
        self.topSwirl = [CCSprite spriteWithSpriteFrameName:@"funnel_02.png"];
        self.topSwirl.position = location;
        self.middleSwirl = [CCSprite spriteWithSpriteFrameName:@"funnel_01.png"];
        self.middleSwirl.position = location;
        self.middleSwirl.scale = 0.9;
        self.middleSwirl.color = ccc3(102, 102, 102);
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"funnel_01.png"]];
        self.topSwirl.opacity = 140;
        self.middleSwirl.opacity = 80;
        self.opacity = 70;
        // Rotating images
        [self.middleSwirl runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:24.0 angle:360]]];
        [self.topSwirl runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5.0 angle:360]]];
        gameObjectType = kEnemyTypeMagneticCell;
        characterState = kStateIdle;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [self.parent addChild:self.middleSwirl z:-1];
    [self.parent addChild:self.topSwirl z:0];
}

- (void)drawMagnetForces
{
    // New realisation with Batched Anti-aliased drawing
    HMVectorNode *drawNode = (HMVectorNode*)[[[self parent] parent] getChildByTag:kDrawNodeTagValue];
    
    float lineWidth = 1;
    ccColor4B lineColor = ccc4(159, 101, 58, 255);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        lineWidth *= 2;
    }
    // Рисуем линий намагничивания от ChildCell к центру магнита
    for (NSString *posValue in cellsPosToDraw) 
    {
        CGPoint cellPos = CGPointFromString(posValue);
        [drawNode drawSegmentFrom:self.position to:cellPos radius:lineWidth color:ccc4FFromccc4B(lineColor)];
    }
    [cellsPosToDraw removeAllObjects];
}

- (void)dealloc
{
    [_topSwirl release];
    [_middleSwirl release];
    
    [cellsPosToDraw release];
    cellsPosToDraw = nil;
    
    [super dealloc];
}

@end
