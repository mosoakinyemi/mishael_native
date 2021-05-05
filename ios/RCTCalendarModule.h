//
//  RCTCalendarModule.h
//  mishael_native
//
//  Created by Moso on 19/04/2021.
//

#import <React/RCTBridgeModule.h>
@import EventKit;

@interface RCTCalendarModule : NSObject <RCTBridgeModule>

@property (strong, nonatomic) EKEventStore *eventStore;
@property (nonatomic) BOOL _hasCalendarPermission;
@property (copy, nonatomic) NSArray *calendarEvents;

- (void) removeEventItem: (NSString *) eventId;
- (EKEvent *) _getEventById: (NSString *) eventId;

+ (void) fetchCalendarEvents;
+ (NSArray *) serializeCalendarEvents:(NSArray *)calendarEvents;

 @end
