//
//  RCTCalendarModule.m
//  mishael_native
//
//  Created by Moso on 19/04/2021.
//
#import "RCTCalendarModule.h"
#import <React/RCTLog.h>

@implementation RCTCalendarModule

RCT_EXPORT_METHOD(createCalendarEvent:(NSString *)name location:(NSString *)location callback:(RCTResponseSenderBlock) callback)
{
  NSNumber *eventId = [NSNumber numberWithInt:123];
  callback(@[eventId]);
  
  RCTLogInfo(@"Demo event creation %@ at %@", name, location);

}
// To export a module named RCTCalendarModule
RCT_EXPORT_MODULE();

@end
