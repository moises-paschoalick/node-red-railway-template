# Deploy and Host Node-RED on Railway

Node-RED is a low-code, flow-based programming tool for wiring together APIs, devices and online services through a visual browser editor. This template deploys Node-RED with a password-protected editor and a persistent volume, so your flows survive every redeploy.

## About Hosting Node-RED

This template deploys a single service: a Node-RED instance built from the official `nodered/node-red` image, with a startup script that secures the editor automatically.

On every start, the container:

- Fixes the ownership of the `/data` volume so Node-RED can write to it.
- Applies the bundled `settings.js` and installs the declared nodes.
- Seeds `flows.json` only on first boot, so flows you create in the editor are never overwritten.
- Protects the editor with the `admin` user, using the password from `ADMIN_PASSWORD` or a randomly generated one.

After deployment:

1. Set the `ADMIN_PASSWORD` variable on the service (recommended). Without it, a new random password is generated on every deploy and printed to the deploy logs, inside the `NODE-RED ADMIN CREDENTIALS` block.
2. Make sure a volume is mounted at `/data` so your flows and credentials persist.
3. Open the service's public domain and log in with the username `admin` and your password.

## Common Use Cases

- Build automations and integrations between APIs with a drag-and-drop interface
- Create HTTP endpoints, webhooks and scheduled jobs without writing a backend
- Collect, transform and route data from IoT devices, MQTT brokers and databases
- Rapidly prototype workflows and internal tools with minimal code

## Dependencies for Node-RED

The Railway template includes all required dependencies: the Node.js runtime, Node-RED and the password provisioning script.

### Deployment Dependencies

- [Node-RED](https://nodered.org)
- [nodered/node-red Docker image](https://hub.docker.com/r/nodered/node-red)
- [bcrypt](https://www.npmjs.com/package/bcrypt)
- [Source repository](https://github.com/moises-paschoalick/node-red-railway-template)

### Environment Variables

| Variable         | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `ADMIN_PASSWORD` | Password for the `admin` user. If empty, a random one is generated on every start. |
| `PORT`           | HTTP port, set automatically by Railway (defaults to `1880`).               |

## Why Deploy Node-RED on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Node-RED on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
