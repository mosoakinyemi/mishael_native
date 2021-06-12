import React from 'react';
import {StyleSheet, View, Text, Button} from 'react-native';

const ListItem = ({
  title,
  location = '',
  onPressUpdate,
  onPressDelete,
  time,
  eventId,
}) => {
  return (
    <View key={eventId} style={styles.container}>
      <View>
        <Text>{title + ' ' + location}</Text>
        <Text>{new Date(time).toLocaleString()}</Text>
      </View>
      <View style={styles.buttonContainer}>
        <Button
          title="Edit"
          color="blue"
          onPress={() => onPressUpdate(eventId)}
        />

        <Button
          title="Delete"
          color="red"
          onPress={() => onPressDelete(eventId)}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  buttonContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  container: {
    justifyContent: 'space-between',
    alignItems: 'center',
    flexDirection: 'row',
    width: '100%',
    borderBottomWidth: 0.8,
    paddingHorizontal: 20,
    paddingVertical: 10,
  },
});

export default ListItem;
