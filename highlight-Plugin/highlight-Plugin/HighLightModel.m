//
//  SharedInstance.m
//  highlight-Plugin
//
//  Created by RobotJi on 13-7-26.
//  Copyright (c) 2013年 xiaojukeji. All rights reserved.
//

#import "HighLightModel.h"

@implementation HighLightModel

-(instancetype)init{
    if (self = [super init]) {
        _lightState = @1;
        _colorHighlight = [NSColor grayColor];
        return self;
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        self.lightState = [coder decodeObjectForKey:@"lightState"];
        self.colorHighlight = [coder decodeObjectForKey:@"colorHighlight"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_lightState forKey:@"lightState"];
    [aCoder encodeObject:_colorHighlight forKey:@"colorHighlight"];
}

@end
