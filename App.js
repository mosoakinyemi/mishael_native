import React from 'react';
import {StyleSheet, View, Button, NativeModules} from 'react-native';

const {CalendarModule} = NativeModules;

const App = () => {
  const onPress = () => {
    CalendarModule.createCalendarEvent('demoName', 'demoLocation', eventId => {
      console.log(`Created a new test event with id: ${eventId}`);
    });
  };
  return (
    <View style={styles.container}>
      <Button
        title="Click to invoke native module!"
        color="#841584"
        onPress={onPress}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default App;
