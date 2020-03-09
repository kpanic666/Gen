//
//  Scene22ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene22ActionLayer.h"

@implementation Scene22ActionLayer

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
        CGPoint cellPos, cellPos1;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background2.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];

        // add ChildCells
        float offset = 25; // Расстояние между элементами куба (между ячейками)
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offset *= 2;
            cellPos = ccp(34, screenSize.height * 0.9);
            cellPos1 = ccp(34, screenSize.height * 0.2);
        }
        else
        {
            cellPos = [Helper convertPosition:ccp(34, 68)]; // Top left corner of Cube
            cellPos1 = [Helper convertPosition:ccp(34, 470)]; // Top left corner of Cube
        }
        
        [self makeCubeWithDimention:2 offset:offset atPos:cellPos];
        [self makeCubeWithDimention:3 offset:offset atPos:cellPos1];
        
        [[GameManager sharedGameManager] setNumOfMaxCells:[GameManager sharedGameManager].numOfTotalCells];
    }
    return self;
}

@end
