// lib/db.ts
import mysql from 'mysql2/promise';

const db = mysql.createPool({
  // En Docker, el contenedor de Next.js se conecta al servicio definido en docker-compose (por ejemplo, "mysql")
  host: process.env.DB_HOST || 'mysql',
  user: process.env.DB_USER || process.env.MYSQL_USER || 'user',
  password: process.env.DB_PASSWORD || process.env.MYSQL_PASSWORD || 'password',
  database: process.env.DB_NAME || process.env.MYSQL_DATABASE || 'mydatabase'
});

export default db;
