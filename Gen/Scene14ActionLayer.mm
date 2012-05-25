//
//  Scene14ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 15.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene14ActionLayer.h"

@implementation Scene14ActionLayer

- (void)makeCubeWithDimention:(int)dim offset:(float)offset atPos:(CGPoint)startPos
{
    // Создаем массив для хранения ссылок на созданные ячейки куба
    id cellsBodyArray[dim][dim];
    
    // Создаем куб и заполняем массив для дальнейшего связывания ячеек джойнтами
    for (int r=0; r < dim; r++)
    {
        for (int c=0; c < dim; c++)
        {
            cellsBodyArray[c][r] = [self createChildCellAtLocation:ccpAdd(startPos, ccp(offset * c, -offset * r))];
        }
    }
    
    // Соединяем элементы куба между собой RevoluteJoint'ами
    b2DistanceJointDef disJointDef;
    disJointDef.localAnchorA.SetZero();
    disJointDef.localAnchorB.SetZero();
    for (int r=0; r < dim; r++)
    {
        for (int c=0; c < dim; c++)
        {
            // Соединяем ячейку с предыдущей в ряду
            if (c > 0)
            {
                ChildCell *tempCell = (ChildCell*)cellsBodyArray[c-1][r];
                disJointDef.bodyA = tempCell.body;
                tempCell = (ChildCell*)cellsBodyArray[c][r];
                disJointDef.bodyB = tempCell.body;
                disJointDef.length = offset / PTM_RATIO;
                world->CreateJoint(&disJointDef);
            }
            // Соединяем ячейку с предыдущей в столбце
            if (r > 0)
            {
                ChildCell *tempCell = (ChildCell*)cellsBodyArray[c][r-1];
                disJointDef.bodyA = tempCell.body;
                tempCell = (ChildCell*)cellsBodyArray[c][r];
                disJointDef.bodyB = tempCell.body;
                disJointDef.length = offset / PTM_RATIO;
                world->CreateJoint(&disJointDef);
            }
            // Соединяем ячейки по диагонали для прочности.
            if (c > 0 && r > 0)
            {
                ChildCell *tempCell = (ChildCell*)cellsBodyArray[c-1][r-1];
                disJointDef.bodyA = tempCell.body;
                tempCell = (ChildCell*)cellsBodyArray[c][r];
                disJointDef.bodyB = tempCell.body;
                // Вычисляем длину гиппотенузы
                disJointDef.length = sqrtf(2 * offset * offset) / PTM_RATIO;
                world->CreateJoint(&disJointDef);
            }
        }
    }
}

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene14bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(888, 313)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(740, 147)];
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell1"];
        [self addChild:groundCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(453, 66)];
        GroundCell *groundCell2 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell2"];
        [self addChild:groundCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(611, 554)];
        GroundCell *groundCell3 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell3"];
        [self addChild:groundCell3 z:-1];
        
        // add ChildCells
        float offset = 15; // Расстояние между элементами куба (между ячейками)
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offset *= 2;
        }
        cellPos = [Helper convertPosition:ccp(34, 34)]; // Top left corner of Cube
        [self makeCubeWithDimention:3 offset:offset atPos:cellPos];
        cellPos = [Helper convertPosition:ccp(34, 470)]; // Top left corner of Cube
        [self makeCubeWithDimention:4 offset:offset atPos:cellPos];
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(585, 192)];
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(585, 425)];
        RedCell *redCell2 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell2 z:-1];
        
        // add MagneticCells
        cellPos = [Helper convertPosition:ccp(770, 256)];
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(482, 362)];
        MagneticCell *magneticCell2 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell2 z:-1];
    }
    return self;
}

@end
