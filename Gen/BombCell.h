//
//  BobmCell.h
//  Gen
//  Как обычная ячейка, только взрывается через промежуток времени после активации и раскидывает другие ячейки
//  Created by Andrey Korikov on 20.07.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ChildCell.h"

@interface BombCell : ChildCell
{
    BOOL activated; // была активирована, но еще не взорвалась
    BOOL exploded; // была взорвана
} 

@property (nonatomic, retain) CCAnimation *boomAnim;
@property (nonatomic, retain) CCAnimation *timerAnim;
@end
