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
