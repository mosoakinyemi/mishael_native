//
//  RCTCalendarModule.m
//  mishael_native
//
//  Created by Moso on 19/04/2021.
//
#import "RCTCalendarModule.h"
#import <React/RCTLog.h>
#import <EventKit/EventKit.h>


@interface RCTCalendarModule ()
@property (nonatomic)NSString *savedEventId;
@end


@implementation RCTCalendarModule
{
  bool hasListeners;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onCreateCalendarEvent"];
}

-(void)startObserving {
    hasListeners = YES;
}

-(void)stopObserving {
    hasListeners = NO;
}

- (void) fireReminder:(NSString *) title
{
  NSString *message = [NSString stringWithFormat:@"%@ is comming up in 1hr", title];
  double delayInSeconds = 10.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    if (self->hasListeners) { // Only send events if listening
      [self sendEventWithName:@"onCreateCalendarEvent" body:@{@"message":message }];
    }
  });

}

- (EKEventStore *)eventStore {
  if (!_eventStore) {
    _eventStore = [[EKEventStore alloc] init];
  }
  return _eventStore;
}

+ (BOOL) hasCalendarPermission
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    return status == EKAuthorizationStatusAuthorized;
}

-(void)_requestPermission
{
  NSLog(@"====Requesting Permission ====");
  EKEventStore *eventStore = [[EKEventStore alloc] init];
  [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (error) {
          NSLog(@"Could not request Calendar Permission");
        }
        else if (granted){
          NSLog(@"Permission Granted Boss");
        }
    }];
}

- (EKCalendarItem *  _Nullable) _getEventById: (NSString *) eventId
{
  return [self.eventStore calendarItemWithIdentifier:eventId];
}

//-------RCT Exports--------//

RCT_EXPORT_METHOD(createCalendarEvent:(NSString *)name
                  location:(NSString *) location
                  resolver:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject)
{

  if([RCTCalendarModule hasCalendarPermission]){
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = name;
    event.location = location;
    event.startDate = [NSDate date]; //today
    event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
    event.calendar = [self.eventStore defaultCalendarForNewEvents];
    NSError *err = nil;
    BOOL success = [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    self.savedEventId = event.eventIdentifier;  //save the event id if you want to access this later
    if (success) {
      resolve(@[self.savedEventId]);
      [self fireReminder:name];
      return;
    }
    reject(@"Saving Failed", @"Could not save event", nil);
    return;
  }
  else{
    NSLog(@"====No Permission ====");
    [self _requestPermission];
  }
}

RCT_EXPORT_METHOD(removeEventItem:(NSString *)eventId
                  resolver:(RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject)
{
  if(![RCTCalendarModule hasCalendarPermission]){
    reject(@"error", @"unauthorized to access calendar", nil);
    return;
  }
      EKEvent* eventToRemove = [self _getEventById:eventId];
      NSLog(@"Our event ID %@", eventId);
      NSLog(@"%@", eventToRemove);
      if (eventToRemove) {
          NSError* error = nil;
          [self.eventStore removeEvent:eventToRemove span:EKSpanThisEvent commit:YES error:&error];
          resolve(@[@"true"]);
          return;
      }
    reject(@"error", @"no event with such Id", nil);
}

RCT_EXPORT_METHOD(fetchCalendarEvents:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject)
{
      if(![RCTCalendarModule hasCalendarPermission]){
        reject(@"error", @"unauthorized to access calendar", nil);
        return;
      }
      NSPredicate *predicate = [self.eventStore
                                predicateForEventsWithStartDate:[NSDate date]
                                endDate:[[NSDate date] dateByAddingTimeInterval:60*60*24]
                                calendars:nil ];
      
      NSArray *calendarEvents = [self.eventStore eventsMatchingPredicate: predicate];
  
      if (calendarEvents) {
        NSLog(@"Calendar Events Found");
        resolve([RCTCalendarModule serializeCalendarEvents:calendarEvents]);
      } else if (calendarEvents == nil) {
          resolve(@[]);
      } else {
          reject(@"error", @"calendar event request error", nil);
      }

}

RCT_EXPORT_METHOD(updateEvent:(NSString *)eventId
                  options:(NSDictionary *) options
                  resolver:(RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject )
{
  if(![RCTCalendarModule hasCalendarPermission]){
    reject(@"error", @"unauthorized to access calendar", nil);
    return;
  }
  
    EKEvent *event  = [self _getEventById:eventId];
    NSString *newTitle = [options valueForKey:@"title"];
    NSString *newLocation = [options valueForKey:@"location"];
    NSError *err = nil;

    if(event) {
      
      if (newTitle) {
        event.title  = newTitle;
      }
      if (newLocation) {
        event.title  = newLocation;
      }
  
      event.calendar = [self.eventStore defaultCalendarForNewEvents];
      [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
      
      
      return;
  }
  reject(@"error", @"No event with the supplied ID", nil);

}

RCT_EXPORT_MODULE();


//-------Serializers 😅--------//

+ (NSMutableDictionary *) serializeCalendarEvent:(EKEvent *)item
{
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
  [dateFormatter setTimeZone:timeZone];
  [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z"];
  
  NSMutableDictionary *serializedItem = [[NSMutableDictionary alloc] init];

  if (item.calendarItemIdentifier) {
    serializedItem[@"id"] = item.calendarItemIdentifier;
  }
  if (item.title) {
    serializedItem[@"title"] = item.title;
  }
  if (item.location) {
    serializedItem[@"location"] = item.location;
  }
  if (item.startDate) {
    serializedItem[@"startDate"] = [dateFormatter stringFromDate:item.startDate];
  }
  if (item.endDate) {
    serializedItem[@"endDate"] = [dateFormatter stringFromDate:item.endDate];
  }
  return serializedItem;
}

+ (NSArray *) serializeCalendarEvents:(NSArray *)calendarEvents
{
  NSMutableArray *serializedCalendarEvents = [[NSMutableArray alloc] init];
  for (EKEvent *event in calendarEvents) {
    [serializedCalendarEvents addObject:[self serializeCalendarEvent:event]];
  }
  return serializedCalendarEvents;
}



@end
