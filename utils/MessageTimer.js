import { useEffect, useState } from 'react';
import { Text } from 'react-native';

export default function MessageTimer({ timestamp, duration }) {
  const [timeLeft, setTimeLeft] = useState('');

  useEffect(() => {
    const calculateTime = () => {
      const expirationTime = timestamp.toDate().getTime() + (duration * 1000);
      const now = Date.now();
      const diff = expirationTime - now;

      if (diff <= 0) {
        setTimeLeft('Expired');
        return;
      }

      const hours = Math.floor(diff / (1000 * 60 * 60));
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      setTimeLeft(`${hours}h ${minutes}m`);
    };

    const interval = setInterval(calculateTime, 60000);
    calculateTime();

    return () => clearInterval(interval);
  }, [timestamp, duration]);

  return <Text style={{ fontSize: 10 }}>{timeLeft}</Text>;
}