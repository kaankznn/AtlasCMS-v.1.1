require("dotenv").config();
const mysql = require("mysql2/promise");

const user = process.env.mysql_user;
const password = process.env.mysql_pw;
const PORT = process.env.port || 3306;
const database = process.env.database || "cms_nodejs";

const pool = mysql.createPool({
  host: "127.0.0.1",
  user: user,
  password: password,
  database: database,
  port: PORT
});

pool.on("error", (err) => {
  console.error("DB POOL ERROR:", err);
});

module.exports = pool;
