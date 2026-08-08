const express = require('express');
const dns = require('dns');
const app = express();

const SERVICE_NAME = process.env.SERVICE_NAME || 'service-c';
const SERVICE_PORT = process.env.SERVICE_PORT || 3003;
const CONSUL_HOST = process.env.CONSUL_HOST || 'localhost';

app.get('/info', (req, res) => {
  res.json({ service: SERVICE_NAME, timestamp: new Date().toISOString() });
});

app.get('/health', (req, res) => res.sendStatus(200));

app.listen(SERVICE_PORT, async () => {
  console.log(`${SERVICE_NAME} running on ${SERVICE_PORT}`);
  await registerWithConsul();
});

async function registerWithConsul() {
  // resolve our own container IP via Docker's embedded DNS
  const { address: ownIp } = await dns.promises.lookup(SERVICE_NAME);

  const payload = {
    ID: `${SERVICE_NAME}-1`,
    Name: SERVICE_NAME,
    Address: ownIp, // real IP now, not a hostname
    Port: parseInt(SERVICE_PORT),
    Check: {
      HTTP: `http://${ownIp}:${SERVICE_PORT}/health`,
      Interval: '10s',
    },
  };

  const res = await fetch(
    `http://${CONSUL_HOST}:8500/v1/agent/service/register`,
    {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    },
  );

  console.log(
    res.ok ? `Registered with Consul as ${ownIp}` : 'Failed to register',
  );
}
