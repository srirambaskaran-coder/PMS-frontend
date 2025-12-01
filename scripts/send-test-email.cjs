// Send a test email using the DB email configuration
const path = require("path");
const { readFileSync } = require("fs");
const sql = require("mssql");
const nodemailer = require("nodemailer");

function loadEnvFile() {
  try {
    const envPath = path.join(__dirname, "..", ".env");
    const env = readFileSync(envPath, "utf8");
    env.split("\n").forEach((line) => {
      line = line.trim();
      if (line && !line.startsWith("#") && line.includes("=")) {
        const [key, ...valueParts] = line.split("=");
        const value = valueParts.join("=").replace(/^['"]|['"]$/g, "");
        process.env[key.trim()] = value;
      }
    });
  } catch (e) {
    console.warn("Could not load .env:", e.message);
  }
}

async function main() {
  loadEnvFile();

  const config = {
    server: process.env.DB_SERVER || "localhost",
    port: parseInt(process.env.DB_PORT || "1433"),
    database: process.env.DB_DATABASE || "PMS_DB",
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: {
      encrypt: process.env.DB_ENCRYPT === "true",
      trustServerCertificate:
        process.env.DB_TRUST_SERVER_CERTIFICATE === "true",
      enableArithAbort: true,
    },
  };

  console.log("Connecting to SQL...");
  const pool = await new sql.ConnectionPool(config).connect();
  console.log("Connected. Fetching email config...");
  const result = await pool.request().execute("dbo.GetEmailConfig");
  const cfg = result.recordset?.[0];
  if (!cfg) throw new Error("No active email config found in DB");

  console.log("Creating transporter...");
  const transporter = nodemailer.createTransport({
    host: cfg.SmtpHost,
    port: cfg.SmtpPort,
    secure: cfg.SmtpPort === 465,
    auth: { user: cfg.SmtpUsername, pass: cfg.SmtpPassword },
  });

  console.log("Verifying transporter...");
  await transporter.verify();
  console.log("Transport verified. Sending message...");

  const to = process.argv[2] || "sridhanu2004@gmail.com";
  const info = await transporter.sendMail({
    from: `"${cfg.FromName}" <${cfg.FromEmail}>`,
    to,
    subject: "PMS Test Email (SMTP config check)",
    html: "<p>This is a test email from Performance Hub to confirm SMTP settings.</p>",
  });

  console.log("Message sent:", info.messageId || info.response);
  await pool.close();
}

main().catch((err) => {
  console.error("Test failed:", err);
  process.exit(1);
});
