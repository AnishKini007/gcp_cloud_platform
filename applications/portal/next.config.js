/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  reactStrictMode: true,
  env: {
    PROJECT_ID: process.env.PROJECT_ID || 'gcloud-platform-484321',
    REGION: process.env.REGION || 'asia-south1',
    API_SERVICE_URL: process.env.API_SERVICE_URL || 'http://api-service:8080',
  },
}

module.exports = nextConfig
