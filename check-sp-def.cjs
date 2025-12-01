const sql = require('mssql');

const config = {
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD || 'YourPassword123',
  server: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'performmgmt',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

async function main() {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query(`
      SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.CreateInitiatedAppraisal')) AS Definition
    `);
    console.log('CreateInitiatedAppraisal SP Definition:');
    console.log(result.recordset[0].Definition);
    await sql.close();
  } catch (err) {
    console.error('Error:', err);
    await sql.close();
  }
}

main();
