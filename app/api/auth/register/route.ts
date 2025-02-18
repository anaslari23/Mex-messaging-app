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
