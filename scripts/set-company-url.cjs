// Set company_url (slug) for a company using stored procedure
require("dotenv").config();
const sql = require("mssql");

async function main() {
  const slug = process.argv[2] || "default";
  const config = {
    server: process.env.DB_SERVER || "localhost",
    port: parseInt(process.env.DB_PORT || "1433"),
    database: process.env.DB_DATABASE || "PMS_DB",
    user: process.env.DB_USER || "pms_app_user",
    password: process.env.DB_PASSWORD,
    options: { encrypt: true, trustServerCertificate: true },
  };

  const pool = await sql.connect(config);

  // Prefer the recently created company named 'Default Company'
  const find = await pool.request().query(`
    SELECT TOP 1 id, name, company_url
    FROM dbo.companies
    ORDER BY created_at DESC`);

  if (find.recordset.length === 0) {
    console.log("No companies found.");
    process.exit(1);
  }
  const company = find.recordset[0];
  console.log("Current company:", company);

  await pool
    .request()
    .input("Id", sql.UniqueIdentifier, company.id)
    .input("CompanyUrl", sql.NVarChar, slug)
    .execute("dbo.UpdateCompany");

  const confirm = await pool
    .request()
    .query(
      `SELECT id, name, company_url FROM dbo.companies WHERE id='${company.id}'`
    );
  console.log("Updated company:", confirm.recordset[0]);

  await pool.close();
}

main().catch((e) => {
  console.error("Error:", e.message);
  process.exit(1);
});
