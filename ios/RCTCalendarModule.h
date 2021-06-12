//
//  RCTCalendarModule.h
//  mishael_native
//
//  Created by Moso on 19/04/2021.
//

#import <React/RCTBridgeModule.h>
@import EventKit;
#import <React/RCTEventEmitter.h>

@interface RCTCalendarModule : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) EKEventStore *eventStore;
@property (nonatomic) BOOL _hasCalendarPermission;
@property (copy, nonatomic) NSArray *calendarEvents;

- (void) removeEventItem: (NSString *) eventId;
- (EKEvent *) _getEventById: (NSString *) eventId;
- (void) fireReminder:(NSString *) title;

+ (void) fetchCalendarEvents;
+ (NSArray *) serializeCalendarEvents:(NSArray *)calendarEvents;

 @end
