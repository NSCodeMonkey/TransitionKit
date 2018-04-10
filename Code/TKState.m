//
//  TKState.m
//  TransitionKit
//
//  Created by Blake Watters on 3/17/13.
//  Copyright (c) 2013 Blake Watters. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TKState.h"

@interface TKState ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy) void (^willEnterStateBlock)(TKState *, TKTransition *);
@property (nonatomic, copy) void (^didEnterStateBlock)(TKState *, TKTransition *);
@property (nonatomic, copy) void (^willExitStateBlock)(TKState *, TKTransition *);
@property (nonatomic, copy) void (^didExitStateBlock)(TKState *, TKTransition *);
@end

@implementation TKState

- (instancetype)initWithName:(NSString *)name
{
    if (![name length]) [NSException raise:NSInvalidArgumentException format:@"The `name` cannot be blank."];
    
    if (self = [super init]) {
        _name = name;
    }
    
    return self;
}

+ (instancetype)stateWithName:(NSString *)name
{
    return [[self alloc] initWithName:name];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p '%@'>", NSStringFromClass([self class]), self, self.name];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TKState class]]) {
        return NO;
    }
    
    return [self isEqualToState:(TKState*)object];
}

- (BOOL)isEqualToState:(TKState*)state
{
    if (!state) {
        return NO;
    }
    
    BOOL haveEqualNames = (!_name && !state->_name) || [_name isEqualToString:state->_name];
    
    return haveEqualNames;
}

- (NSUInteger)hash {
    return [_name hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    TKState *copiedState = [[[self class] allocWithZone:zone] init];
    copiedState.name = self.name;
    copiedState.willEnterStateBlock = self.willEnterStateBlock;
    copiedState.didEnterStateBlock = self.didEnterStateBlock;
    copiedState.willExitStateBlock = self.willExitStateBlock;
    copiedState.didExitStateBlock = self.didExitStateBlock;
    return copiedState;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
}

@end
