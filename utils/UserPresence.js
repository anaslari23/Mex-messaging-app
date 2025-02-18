import { useEffect, useState } from 'react';
import firestore from '@react-native-firebase/firestore';

export function usePresence(userId) {
  const [isOnline, setIsOnline] = useState(false);

  useEffect(() => {
    if (!userId) return;

    const userRef = firestore().collection('users').doc(userId);
    
    const unsubscribe = userRef.onSnapshot((doc) => {
      setIsOnline(doc.data()?.isOnline || false);
    });

    return () => unsubscribe();
  }, [userId]);

  return isOnline;
}

// Update user presence when app state changes
AppState.addEventListener('change', (state) => {
  if (auth().currentUser?.uid) {
    firestore().collection('users').doc(auth().currentUser.uid)
      .update({
        isOnline: state === 'active',
        lastSeen: firestore.FieldValue.serverTimestamp()
      });
  }
});