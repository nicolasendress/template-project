import type { NextConfig } from "next";
import type { Configuration } from "webpack";

const nextConfig: NextConfig = {
  webpack: (config: Configuration, { dev }) => {
    if (dev) {
      console.log("🔄 Habilitando Webpack con Polling...");
      config.watchOptions = {
        poll: 0, // Verifica cambios cada 1s
        aggregateTimeout: 0, // Reduce latencia en cambios
        ignored: /node_modules/, // Ignora node_modules
      };
    }
    return config;
  },
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "cdn.simpleicons.org" },
      { protocol: "https", hostname: "img.icons8.com" },
    ],
  },
};

export default nextConfig;
