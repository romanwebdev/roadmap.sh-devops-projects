const express = require('express');
const dns = require('dns');
const dgram = require('dgram');
const dnsPacket = require('dns-packet');

const app = express();

const CONSUL_DNS_HOST = process.env.CONSUL_DNS_HOST || 'localhost';
const CONSUL_DNS_PORT = parseInt(process.env.CONSUL_DNS_PORT) || 8600;

let resolver;

async function initResolver() {
  const { address } = await dns.promises.lookup(CONSUL_DNS_HOST);
  resolver = new dns.promises.Resolver();
  resolver.setServers([`${address}:${CONSUL_DNS_PORT}`]);
  console.log(`Consul DNS resolver pointed at ${address}:${CONSUL_DNS_PORT}`);
}

// Primary: Node's built-in resolver
async function resolveViaNodeDns(service) {
  const srvName = `${service}.service.consul`;
  const [addresses, srvRecords] = await Promise.all([
    resolver.resolve4(srvName),
    resolver.resolveSrv(srvName)
  ]);
  if (!addresses.length || !srvRecords.length) {
    throw new Error('empty DNS result');
  }
  return { ip: addresses[0], port: srvRecords[0].port };
}

// Fallback: raw UDP DNS queries straight to Consul, bypassing Node's resolver entirely.
// Sends two separate queries (A and SRV) rather than relying on Consul including
// an A record in the SRV response's additional section — Consul doesn't always do that.
function rawUdpQuery(name, type) {
  return new Promise((resolve, reject) => {
    const query = dnsPacket.encode({
      type: 'query',
      id: Math.floor(Math.random() * 65534),
      flags: dnsPacket.RECURSION_DESIRED,
      questions: [{ type, name }],
      additionals: [{ type: 'OPT', name: '.', udpPayloadSize: 4096 }]
    });

    const socket = dgram.createSocket('udp4');
    const timeout = setTimeout(() => {
      socket.close();
      reject(new Error(`DNS ${type} query timed out`));
    }, 3000);

    socket.once('message', (msg) => {
      clearTimeout(timeout);
      socket.close();
      try {
        const response = dnsPacket.decode(msg);
        const record = response.answers.find(a => a.type === type);
        if (!record) return reject(new Error(`no ${type} record in response`));
        resolve(record.data);
      } catch (err) {
        reject(err);
      }
    });

    socket.once('error', (err) => {
      clearTimeout(timeout);
      reject(err);
    });

    socket.send(query, CONSUL_DNS_PORT, CONSUL_DNS_HOST);
  });
}

async function resolveViaRawUdp(service) {
  const srvName = `${service}.service.consul`;
  const [ip, srv] = await Promise.all([
    rawUdpQuery(srvName, 'A'),
    rawUdpQuery(srvName, 'SRV')
  ]);
  return { ip, port: srv.port };
}

async function discoverService(service) {
  try {
    return await resolveViaNodeDns(service);
  } catch (err) {
    console.warn(`Node DNS resolver failed (${err.message}), falling back to raw UDP`);
    return await resolveViaRawUdp(service);
  }
}

app.get('/:service/*', async (req, res) => {
  const { service } = req.params;
  const path = req.params[0];

  try {
    const { ip, port } = await discoverService(service);
    const target = `http://${ip}:${port}/${path}`;
    const proxied = await fetch(target);
    const data = await proxied.json();
    res.json(data);
  } catch (err) {
    res.status(503).json({ error: `Discovery failed: ${err.message}` });
  }
});

initResolver()
  .then(() => {
    app.listen(8080, () => console.log('Gateway on 8080'));
  })
  .catch(err => {
    console.error('Failed to init DNS resolver:', err);
    process.exit(1);
  });
