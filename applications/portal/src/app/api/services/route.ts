import { NextResponse } from 'next/server'

interface Service {
  name: string
  healthUrl: string | null
  url: string | null
  docs?: string | null
}

export async function GET() {
  const services: Service[] = [
    {
      name: 'API Service',
      healthUrl: 'http://34.47.232.24/live',
      url: 'http://34.47.232.24/docs',
      docs: 'http://34.47.232.24/docs'
    },
    {
      name: 'Worker Service',
      healthUrl: 'http://34.47.246.239/health',
      url: 'http://34.47.246.239/metrics',
      docs: 'http://34.47.246.239/metrics'
    },
    {
      name: 'Frontend App',
      healthUrl: 'http://34.180.1.157',
      url: 'http://34.180.1.157',
      docs: 'http://34.180.1.157'
    }
  ]

  const results = await Promise.all(
    services.map(async (service) => {
      if (!service.healthUrl) {
        return {
          name: service.name,
          status: 'unknown',
          url: service.url,
          docs: service.docs
        }
      }

      try {
        const controller = new AbortController()
        const timeoutId = setTimeout(() => controller.abort(), 3000)
        
        const response = await fetch(service.healthUrl, {
          signal: controller.signal,
          cache: 'no-store'
        })
        
        clearTimeout(timeoutId)
        
        return {
          name: service.name,
          status: response.ok ? 'healthy' : 'unhealthy',
          url: service.url,
          docs: service.docs,
          statusCode: response.status
        }
      } catch (error) {
        return {
          name: service.name,
          status: 'unhealthy',
          url: service.url,
          docs: service.docs,
          error: error instanceof Error ? error.message : 'Unknown error'
        }
      }
    })
  )

  return NextResponse.json(results)
}
