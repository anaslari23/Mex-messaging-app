import { useState } from 'react';
import { View, TouchableOpacity, Text } from 'react-native';
import EmojiPicker from 'rn-emoji-keyboard';

export default function MessageReactions({ messageId }) {
  const [showPicker, setShowPicker] = useState(false);
  const [reactions, setReactions] = useState([]);

  const handleReaction = async (emoji) => {
    // Update Firestore or your backend
    await firestore()
      .collection('messages')
      .doc(messageId)
      .update({
        reactions: firestore.FieldValue.arrayUnion({
          emoji,
          userId: currentUser.uid
        })
      });
  };

  return (
    <View>
      <TouchableOpacity onPress={() => setShowPicker(true)}>
        <Text>➕</Text>
      </TouchableOpacity>

      <EmojiPicker
        open={showPicker}
        onClose={() => setShowPicker(false)}
        onEmojiSelected={({ emoji }) => handleReaction(emoji)}
      />
    </View>
  );
}