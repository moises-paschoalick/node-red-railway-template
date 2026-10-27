# Node-RED for Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/-7V17e?referralCode=1JjR_W&utm_medium=integration&utm_source=template&utm_campaign=generic)

Docker image of [Node-RED](https://nodered.org) with a password-protected editor, ready to deploy on [Railway](https://railway.com) or to run locally with Docker.

## Structure

```
.
├── Dockerfile            # Image based on nodered/node-red
├── railway.toml          # Railway deploy template
├── docker-compose.yml    # Local run
├── .env.example          # Environment variables
├── data/                 # Node-RED userDir template
│   ├── settings.js       # Node-RED settings (port reads $PORT)
│   ├── flows.json        # Initial flows (used only on first boot)
│   └── package.json      # Dependencies (bcrypt, used by the password script)
└── scripts/
    ├── init.sh           # Entrypoint: prepares /data, sets the password and starts Node-RED
    └── user-provision.js # Generates the bcrypt hash and writes adminAuth into settings.js
```

## How startup works

On every container start, `scripts/init.sh` (running as root):

1. Fixes `/data` ownership if the volume was mounted as root (common on Railway).
2. Copies `settings.js` and `package.json` from the image (`/data-template`) to `/data`.
3. Copies `flows.json` **only if it does not exist yet**: flows created in the editor are preserved across deploys.
4. Restores `node_modules` if it is missing or if `package.json` changed.
5. Runs `user-provision.js`, which writes the `adminAuth` block into `settings.js` with the `admin` user and:
   - the password from `ADMIN_PASSWORD`, if set, or
   - a random 20-character password, printed to the logs.
6. Starts Node-RED as the `node-red` user.

## Environment variables

| Variable         | Description                                                          | Required |
|------------------|----------------------------------------------------------------------|----------|
| `ADMIN_PASSWORD` | Password for the `admin` user. If empty, a new one is generated on every start. | No (recommended) |
| `PORT`           | HTTP port. Railway sets it automatically; defaults to `1880`.        | No |

> Without `ADMIN_PASSWORD`, the password **changes on every redeploy**. Set it to keep a fixed password.

## Deploy on Railway

### One click

Click the **Deploy on Railway** button above, set `ADMIN_PASSWORD` and deploy.

### From the dashboard

1. Push this directory to a GitHub repository.
2. On Railway: **New Project → Deploy from GitHub repo** and select the repository.
   `railway.toml` makes Railway build from the `Dockerfile` and configures the healthcheck.
3. Under **Variables**, add `ADMIN_PASSWORD`.
4. Under **Volumes**, create a volume with mount path **`/data`** (without a volume, flows are lost on every deploy).
5. Under **Settings → Networking**, click **Generate Domain** to get the public URL.

### From the CLI

```bash
npm install -g @railway/cli
railway login
railway init
railway variables --set "ADMIN_PASSWORD=your-password"
railway up
```

Then create the `/data` volume and generate the domain from the dashboard, as in steps 4 and 5 above.

### Where to find the generated password

If `ADMIN_PASSWORD` was not set, open **Deployments → (latest deploy) → Logs** and look for:

```
============================================================
🚀 NODE-RED ADMIN CREDENTIALS
============================================================
👤 Username: admin
🔑 Password: ********************
============================================================
```

## Running locally

```bash
cp .env.example .env      # set ADMIN_PASSWORD
docker compose up --build
```

Open http://localhost:1880 and log in with `admin` and the password you set (or the one shown in `docker compose logs`).

Without compose:

```bash
docker build -t node-red .
docker run --rm -p 1880:1880 -e ADMIN_PASSWORD=your-password -v node_red_data:/data node-red
```

## Customization

- **Initial flows:** replace `data/flows.json` with a Node-RED export. It is only applied when the volume does not have a `flows.json` yet.
- **Additional nodes:** add packages to `data/package.json` (e.g. `"node-red-dashboard": "^3.6.0"`). Since `node_modules` is restored from the image whenever this file changes, declare nodes here instead of installing them from the palette.
- **Settings:** edit `data/settings.js`. It is overwritten in the volume on every deploy, so changes made directly inside the container do not persist.
