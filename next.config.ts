import type { NextConfig } from "next";
import type { Configuration } from "webpack";

const nextConfig: NextConfig = {
  webpack: (config: Configuration, { dev }) => {
    if (dev) {
      // Configura watchOptions para desarrollo: sin delay y polling inmediato.
      config.watchOptions = {
        poll: 0,
        aggregateTimeout: 0
      };
    }
    return config;
  },
};

export default nextConfig;
