'use client'

import { useEffect, useState } from 'react'
import { FaServer, FaDatabase, FaChartBar, FaCloud, FaCog, FaCheckCircle, FaExclamationCircle } from 'react-icons/fa'

interface ServiceStatus {
  name: string
  status: 'healthy' | 'unhealthy' | 'unknown'
  url?: string
  docs?: string
  statusCode?: number
  error?: string
}

export default function Home() {
  const [services, setServices] = useState<ServiceStatus[]>([
    { name: 'API Service', status: 'unknown' },
    { name: 'Worker Service', status: 'unknown' },
    { name: 'Frontend App', status: 'unknown' },
  ])

  const projectId = process.env.NEXT_PUBLIC_PROJECT_ID || 'gcloud-platform-484321'
  const region = process.env.NEXT_PUBLIC_REGION || 'asia-south1'

  useEffect(() => {
    // Check service health on load
    checkServiceHealth()
    
    // Refresh every 30 seconds
    const interval = setInterval(checkServiceHealth, 30000)
    return () => clearInterval(interval)
  }, [])

  const checkServiceHealth = async () => {
    try {
      const response = await fetch('/api/services')
      const data = await response.json()
      setServices(data)
    } catch (error) {
      console.error('Failed to check service health:', error)
    }
  }

  const resources = [
    {
      title: 'Cloud Console',
      description: 'GCP Project Dashboard',
      icon: <FaCloud className="w-8 h-8" />,
      url: `https://console.cloud.google.com/home/dashboard?project=${projectId}`,
      category: 'console'
    },
    {
      title: 'GKE Clusters',
      description: 'Kubernetes cluster management',
      icon: <FaServer className="w-8 h-8" />,
      url: `https://console.cloud.google.com/kubernetes/list?project=${projectId}`,
      category: 'console'
    },
    {
      title: 'Cloud SQL',
      description: 'Database instances',
      icon: <FaDatabase className="w-8 h-8" />,
      url: `https://console.cloud.google.com/sql/instances?project=${projectId}`,
      category: 'console'
    },
    {
      title: 'Cloud Monitoring',
      description: 'Metrics and dashboards',
      icon: <FaChartBar className="w-8 h-8" />,
      url: `https://console.cloud.google.com/monitoring?project=${projectId}`,
      category: 'monitoring'
    },
    {
      title: 'Cloud Logging',
      description: 'Application logs',
      icon: <FaCog className="w-8 h-8" />,
      url: `https://console.cloud.google.com/logs/query?project=${projectId}`,
      category: 'monitoring'
    },
    {
      title: 'BigQuery',
      description: 'Data warehouse',
      icon: <FaChartBar className="w-8 h-8" />,
      url: `https://console.cloud.google.com/bigquery?project=${projectId}`,
      category: 'data'
    },
    {
      title: 'Cloud Storage',
      description: 'Object storage buckets',
      icon: <FaCloud className="w-8 h-8" />,
      url: `https://console.cloud.google.com/storage/browser?project=${projectId}`,
      category: 'data'
    },
    {
      title: 'Cloud Build',
      description: 'CI/CD pipelines',
      icon: <FaCog className="w-8 h-8" />,
      url: `https://console.cloud.google.com/cloud-build/builds?project=${projectId}`,
      category: 'cicd'
    },
  ]

  const StatusIcon = ({ status }: { status: string }) => {
    if (status === 'healthy') return <FaCheckCircle className="text-success" />
    if (status === 'unhealthy') return <FaExclamationCircle className="text-danger" />
    return <div className="w-4 h-4 border-2 border-gray-400 border-t-transparent rounded-full animate-spin" />
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-white mb-4">
            GCP Cloud Infrastructure Platform
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-300">
            Infrastructure with Terraform & CI/CD
          </p>
          <div className="mt-4 flex justify-center gap-4 text-sm text-gray-500 dark:text-gray-400">
            <span>Project: <strong>{projectId}</strong></span>
            <span>•</span>
            <span>Region: <strong>{region}</strong></span>
          </div>
        </div>

        {/* Service Status */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-8">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">Service Status</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {services.map((service) => {
              const ServiceCard = service.url ? 'a' : 'div'
              const cardProps = service.url
                ? {
                    href: service.url,
                    target: '_blank',
                    rel: 'noopener noreferrer',
                    className: 'flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors cursor-pointer'
                  }
                : {
                    className: 'flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700 rounded-lg'
                  }

              return (
                <div key={service.name} className="relative">
                  <ServiceCard {...cardProps}>
                    <div className="flex-1">
                      <span className="font-medium text-gray-900 dark:text-white block">
                        {service.name}
                      </span>
                      {service.url && (
                        <span className="text-xs text-blue-600 dark:text-blue-400 block mt-1">
                          {service.name === 'API Service' 
                            ? 'View API Docs →' 
                            : service.name === 'Worker Service'
                            ? 'View Metrics →'
                            : service.name === 'Frontend App'
                            ? 'Chat with AI →'
                            : 'Click to open →'}
                        </span>
                      )}
                    </div>
                    <StatusIcon status={service.status} />
                  </ServiceCard>
                </div>
              )
            })}
          </div>
        </div>

        {/* Quick Links */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-8">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">Quick Access</h2>
          
          {/* Console & Management */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-3">Console & Management</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {resources.filter(r => r.category === 'console').map((resource) => (
                <a
                  key={resource.title}
                  href={resource.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-start p-4 bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900 dark:to-blue-800 rounded-lg hover:shadow-md transition-shadow"
                >
                  <div className="text-primary mr-4">{resource.icon}</div>
                  <div>
                    <h4 className="font-semibold text-gray-900 dark:text-white">{resource.title}</h4>
                    <p className="text-sm text-gray-600 dark:text-gray-300">{resource.description}</p>
                  </div>
                </a>
              ))}
            </div>
          </div>

          {/* Monitoring */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-3">Monitoring & Observability</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {resources.filter(r => r.category === 'monitoring').map((resource) => (
                <a
                  key={resource.title}
                  href={resource.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-start p-4 bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900 dark:to-green-800 rounded-lg hover:shadow-md transition-shadow"
                >
                  <div className="text-success mr-4">{resource.icon}</div>
                  <div>
                    <h4 className="font-semibold text-gray-900 dark:text-white">{resource.title}</h4>
                    <p className="text-sm text-gray-600 dark:text-gray-300">{resource.description}</p>
                  </div>
                </a>
              ))}
            </div>
          </div>

          {/* Data & Storage */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-3">Data & Storage</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {resources.filter(r => r.category === 'data').map((resource) => (
                <a
                  key={resource.title}
                  href={resource.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-start p-4 bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900 dark:to-purple-800 rounded-lg hover:shadow-md transition-shadow"
                >
                  <div className="text-purple-600 mr-4">{resource.icon}</div>
                  <div>
                    <h4 className="font-semibold text-gray-900 dark:text-white">{resource.title}</h4>
                    <p className="text-sm text-gray-600 dark:text-gray-300">{resource.description}</p>
                  </div>
                </a>
              ))}
            </div>
          </div>

          {/* CI/CD */}
          <div>
            <h3 className="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-3">CI/CD & Deployment</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {resources.filter(r => r.category === 'cicd').map((resource) => (
                <a
                  key={resource.title}
                  href={resource.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-start p-4 bg-gradient-to-br from-orange-50 to-orange-100 dark:from-orange-900 dark:to-orange-800 rounded-lg hover:shadow-md transition-shadow"
                >
                  <div className="text-warning mr-4">{resource.icon}</div>
                  <div>
                    <h4 className="font-semibold text-gray-900 dark:text-white">{resource.title}</h4>
                    <p className="text-sm text-gray-600 dark:text-gray-300">{resource.description}</p>
                  </div>
                </a>
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-gray-600 dark:text-gray-400">
          <p>Infrastructure as Code | CI/CD Automation | Enterprise Security</p>
          <p className="text-sm mt-2">Built with Terraform, GKE, and Cloud Native Technologies</p>
        </div>
      </div>
    </main>
  )
}
