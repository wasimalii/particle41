// app.js

const express = require('express');
const app = express();
const port = 5000;

app.get('/', (req, res) => {

  const timestamp = new Date().toISOString();

  const ipAddress = req.ip;

  res.json({
    timestamp: timestamp,
    ip: ipAddress
  });
});

// start the application on port 5000
app.listen(port, () => {
  console.log(`Server is running. pls hit curl http://localhost:${port} .`);
});

