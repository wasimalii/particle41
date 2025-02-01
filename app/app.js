const express = require('express');
const app = express();
const port = 5000;

app.get('/', (req, res) => {
  const timestamp = new Date().toISOString();
  const ipAddress = req.ip;

  console.log(`[${timestamp}] Request received from IP: ${ipAddress}`);

  res.json({
    message: "Welcome to my API!",
    timestamp: timestamp,
    ip: ipAddress
  });
});

// Log message when user hits "http://myendpoint/"
app.get('/myendpoint', (req, res) => {
  const timestamp = new Date().toISOString();
  const ipAddress = req.ip;

  console.log(`[${timestamp}] User accessed /myendpoint from IP: ${ipAddress}`);

  res.json({
    message: "Hello! You have reached /myendpoint.",
    timestamp: timestamp,
    ip: ipAddress
  });
});

// Start the application on port 5000
app.listen(port, () => {
  console.log(`Server is running. Please hit curl http://localhost:${port} .`);
});
