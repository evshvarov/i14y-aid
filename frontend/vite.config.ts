import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/i14y-aid/api": {
        target: "http://localhost:57337",
        changeOrigin: true,
      },
    },
  },
});
