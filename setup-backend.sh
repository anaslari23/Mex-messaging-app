#!/bin/bash

# Create necessary directories
mkdir -p prisma
mkdir -p app/api/auth/register
mkdir -p app/api/messages
mkdir -p app/api/socket
mkdir -p lib

# Create prisma schema
cat > prisma/schema.prisma << 'EOL'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            String    @id @default(cuid())
  email         String    @unique
  username      String    @unique
  passwordHash  String
  name          String?
  avatar        String?
  status        String?
  lastSeen      DateTime  @default(now())
  publicKey     String    
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  
  sentMessages     Message[]  @relation("SentMessages")
  receivedMessages Message[]  @relation("ReceivedMessages")
  groups           Group[]    @relation("GroupMembers")
  ownedGroups      Group[]    @relation("GroupOwner")
  contacts         User[]     @relation("UserContacts")
  contactOf        User[]     @relation("UserContacts")
}

model Message {
  id          String    @id @default(cuid())
  content     String    
  type        String    @default("TEXT")
  metadata    Json?     
  senderId    String
  receiverId  String?
  groupId     String?
  readAt      DateTime?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  sender      User      @relation("SentMessages", fields: [senderId], references: [id])
  receiver    User?     @relation("ReceivedMessages", fields: [receiverId], references: [id])
  group       Group?    @relation(fields: [groupId], references: [id])
}

model Group {
  id          String    @id @default(cuid())
  name        String
  avatar      String?
  ownerId     String
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  owner       User      @relation("GroupOwner", fields: [ownerId], references: [id])
  members     User[]    @relation("GroupMembers")
  messages    Message[]
}
EOL

# Create register route
cat > app/api/auth/register/route.ts << 'EOL'
import { hash } from 'bcryptjs'
import { prisma } from '@/lib/prisma'
import { generateKeyPair } from '@/lib/encryption'

export async function POST(req: Request) {
  try {
    const { email, username, password, name } = await req.json()

    if (!email || !username || !password) {
      return new Response('Missing required fields', { status: 400 })
    }

    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { email },
          { username }
        ]
      }
    })

    if (existingUser) {
      return new Response('User already exists', { status: 409 })
    }

    const { publicKey, privateKey } = await generateKeyPair()

    const hashedPassword = await hash(password, 12)
    const user = await prisma.user.create({
      data: {
        email,
        username,
        name,
        passwordHash: hashedPassword,
        publicKey
      }
    })

    return Response.json({
      id: user.id,
      email: user.email,
      username: user.username,
      name: user.name
    })

  } catch (error) {
    console.error('Registration error:', error)
    return new Response('Internal server error', { status: 500 })
  }
}
EOL

# Create messages route
cat > app/api/messages/route.ts << 'EOL'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { encryptMessage } from '@/lib/encryption'

export async function POST(req: Request) {
  try {
    const session = await auth()
    if (!session) {
      return new Response('Unauthorized', { status: 401 })
    }

    const { content, receiverId, type = 'TEXT', metadata } = await req.json()

    const receiver = await prisma.user.findUnique({
      where: { id: receiverId },
      select: { publicKey: true }
    })

    if (!receiver) {
      return new Response('Receiver not found', { status: 404 })
    }

    const encryptedContent = await encryptMessage(content, receiver.publicKey)

    const message = await prisma.message.create({
      data: {
        content: encryptedContent,
        type,
        metadata,
        senderId: session.user.id,
        receiverId
      },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
            name: true,
            avatar: true
          }
        }
      }
    })

    return Response.json(message)

  } catch (error) {
    console.error('Message error:', error)
    return new Response('Internal server error', { status: 500 })
  }
}
EOL

# Create socket route
cat > app/api/socket/route.ts << 'EOL'
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
EOL

# Create encryption utility
cat > lib/encryption.ts << 'EOL'
import { webcrypto } from 'crypto'

export async function generateKeyPair() {
  const keyPair = await webcrypto.subtle.generateKey(
    {
      name: 'RSA-OAEP',
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: 'SHA-256'
    },
    true,
    ['encrypt', 'decrypt']
  )

  const publicKey = await webcrypto.subtle.exportKey('spki', keyPair.publicKey)
  const privateKey = await webcrypto.subtle.exportKey('pkcs8', keyPair.privateKey)

  return {
    publicKey: Buffer.from(publicKey).toString('base64'),
    privateKey: Buffer.from(privateKey).toString('base64')
  }
}

export async function encryptMessage(message: string, publicKeyBase64: string) {
  const publicKey = await webcrypto.subtle.importKey(
    'spki',
    Buffer.from(publicKeyBase64, 'base64'),
    {
      name: 'RSA-OAEP',
      hash: 'SHA-256'
    },
    true,
    ['encrypt']
  )

  const encoded = new TextEncoder().encode(message)
  const encrypted = await webcrypto.subtle.encrypt(
    { name: 'RSA-OAEP' },
    publicKey,
    encoded
  )

  return Buffer.from(encrypted).toString('base64')
}

export async function decryptMessage(encryptedMessage: string, privateKeyBase64: string) {
  const privateKey = await webcrypto.subtle.importKey(
    'pkcs8',
    Buffer.from(privateKeyBase64, 'base64'),
    {
      name: 'RSA-OAEP',
      hash: 'SHA-256'
    },
    true,
    ['decrypt']
  )

  const decrypted = await webcrypto.subtle.decrypt(
    { name: 'RSA-OAEP' },
    privateKey,
    Buffer.from(encryptedMessage, 'base64')
  )

  return new TextDecoder().decode(decrypted)
}
EOL

# Create .env file
cat > .env << 'EOL'
DATABASE_URL="postgresql://your-username:your-password@localhost:5432/mex_messaging"
NEXTAUTH_SECRET="your-secret-key"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
SOCKET_PORT=3001
EOL

# Make the script executable
chmod +x setup-backend.sh

echo "Backend files have been created successfully!"
echo "Next steps:"
echo "1. Update the DATABASE_URL in .env with your PostgreSQL credentials"
echo "2. Run 'npm install' to install dependencies"
echo "3. Run 'npx prisma generate' to generate Prisma client"
echo "4. Run 'npx prisma migrate dev' to create database tables"
echo "5. Run 'npm run dev' to start the development server"