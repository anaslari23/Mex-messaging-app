import { createServer } from 'http'
import { Server } from 'socket.io'
import { auth } from '@/lib/auth'

const httpServer = createServer()
const io = new Server(httpServer, {
  cors: {
    origin: process.env.NEXT_PUBLIC_APP_URL,
    methods: ['GET', 'POST']
  }
})

const userSockets = new Map()

io.on('connection', async (socket) => {
  try {
    const session = await auth()
    if (!session) {
      socket.disconnect()
      return
    }

    const userId = session.user.id

    userSockets.set(userId, socket)

    socket.on('send_message', async (data) => {
      const { receiverId, content, type, metadata } = data

      const receiverSocket = userSockets.get(receiverId)
      if (receiverSocket) {
        receiverSocket.emit('new_message', {
          senderId: userId,
          content,
          type,
          metadata,
          createdAt: new Date()
        })
      }
    })

    socket.on('typing', ({ receiverId }) => {
      const receiverSocket = userSockets.get(receiverId)
      if (receiverSocket) {
        receiverSocket.emit('user_typing', { userId })
      }
    })

    socket.on('disconnect', () => {
      userSockets.delete(userId)
    })

  } catch (error) {
    console.error('Socket error:', error)
    socket.disconnect()
  }
})

httpServer.listen(process.env.SOCKET_PORT || 3001)

export const config = {
  api: {
    bodyParser: false,
  },
}
