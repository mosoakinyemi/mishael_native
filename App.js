import React from 'react';
import {StyleSheet, View, Button, NativeModules} from 'react-native';

const {CalendarModule} = NativeModules;

const App = () => {
  const onPress = () => {
    CalendarModule.createCalendarEvent('demoName', 'demoLocation');
  };
  return (
    <View style={styles.backgroundStyle}>
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
