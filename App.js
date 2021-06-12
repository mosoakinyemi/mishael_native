import React from 'react';
import {
  StyleSheet,
  View,
  Button,
  NativeModules,
  NativeEventEmitter,
  Alert,
  Text,
} from 'react-native';
import ListItem from './ios/src/ListItem';

const {CalendarModule} = NativeModules;
const calendarEventEmitter = new NativeEventEmitter(CalendarModule);

const App = () => {
  const [calendarEvents, setCalendarEvents] = React.useState([]);

  React.useEffect(() => {
    const subscription = calendarEventEmitter.addListener(
      'onCreateCalendarEvent',
      onCalendarEvent,
    );
    return () => {
      subscription.remove();
    };
  }, [onCalendarEvent]);

  const onCalendarEvent = event => {
    alert(event.message);
  };

  const onPress = async () => {
    try {
      const eventId = await CalendarModule.createCalendarEvent(
        'Real Party',
        'Zoom call',
      );
      Alert.alert(`Event added successfully`);
      await fetchCalendarEvents();
    } catch (e) {
      console.error(e);
    }
  };

  const fetchCalendarEvents = async () => {
    try {
      const savedEvents = await CalendarModule.fetchCalendarEvents();
      setCalendarEvents(savedEvents);
    } catch (e) {
      console.log(e);
    }
  };

  const deleteEvent = async eventId => {
    try {
      await CalendarModule.removeEventItem(eventId);
      Alert.alert(`Deleted events successfully!`);
      await fetchCalendarEvents();
    } catch (e) {
      console.log({e});
    }
  };
  const updateEvent = async eventId => {
    try {
      console.log('Selected ID', eventId);
      await CalendarModule.updateEvent(eventId, {
        location: 'Updated Location 🙂',
      });

      await fetchCalendarEvents();
    } catch (e) {
      console.log(e);
    }
  };

  return (
    <View style={styles.container}>
      <Text>Calendar Events</Text>
      {calendarEvents.map(event => {
        return (
          <ListItem
            key={event?.id}
            eventId={event?.id}
            title={event?.title}
            location={event?.location}
            onPressDelete={deleteEvent}
            onPressUpdate={updateEvent}
            time={event?.startDate}
          />
        );
      })}
      <Button title="Add Event!" color="#841584" onPress={onPress} />

      <Button
        title="Fetch Calendar Events"
        color="hotpink"
        onPress={fetchCalendarEvents}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    marginTop: 80,
  },
});

export default App;
