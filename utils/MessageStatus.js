import { useEffect, useState } from 'react';
import { View, Text } from 'react-native';
import firestore from '@react-native-firebase/firestore';

export default function MessageStatus({ messageId, userId }) {
  const [status, setStatus] = useState('sent');

  useEffect(() => {
    const unsubscribe = firestore()
      .collection('messages')
      .doc(messageId)
      .onSnapshot((doc) => {
        const data = doc.data();
        if (data?.readBy?.includes(userId)) {
          setStatus('read');
        } else if (data?.deliveredTo?.includes(userId)) {
          setStatus('delivered');
        }
      });

    return () => unsubscribe();
  }, [messageId, userId]);

  return (
    <View style={{ flexDirection: 'row' }}>
      {status === 'read' && <Text>✓✓</Text>}
      {status === 'delivered' && <Text>✓</Text>}
      {status === 'sent' && <Text>🕗</Text>}
    </View>
  );
}