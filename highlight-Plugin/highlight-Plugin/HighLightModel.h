//
//  SharedInstance.h
//  highlight-Plugin
//
//  Created by RobotJi on 13-7-26.
//  Copyright (c) 2013年 xiaojukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHighLight @"kHighLight_plugin"

@interface HighLightModel : NSObject<NSCoding>

@property(nonatomic,strong)NSColor *colorHighlight;
@property(nonatomic)NSNumber *lightState;//0:close , 1:open

@end
