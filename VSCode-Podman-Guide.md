# 🧠 VS Code + Podman for Odoo Development

This guide shows how to set up **Visual Studio Code** (VS Code) for Odoo development using the [odoo-podman](https://github.com/waltherB/odoo-podman) repository and **Podman** as the container engine.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Clone the Repository](#clone-the-repository)
- [Start the Podman Environment](#start-the-podman-environment)
- [Open the Project in VS Code](#open-the-project-in-vs-code)
- [Install Odoo Extension for VS Code](#install-odoo-extension-for-vs-code)
- [Configure Python Environment](#configure-python-environment)
- [Debugging Odoo with VS Code + debugpy](#debugging-odoo-with-vs-code--debugpy)
- [Automate debugpy in Container](#automate-debugpy-in-container)
- [Stop the Environment](#stop-the-environment)
- [Optional: Dev Containers Support](#optional-dev-containers-support)
- [Resources](#resources)

---

## 🚀 Prerequisites
- [VS Code](https://code.visualstudio.com/) installed
- [Podman](https://podman.io/) and [podman-compose](https://github.com/containers/podman-compose) installed
- Git and Python (for local linting/testing)
- Recommended VS Code extensions:
  - **Python**
  - **Pylance**
  - **Dev Containers**
  - **Remote - Containers**
  - **ESLint** / **Ruff**
  - **Odoo VS Code Extension**: [vscode-odoo](https://github.com/odoo-ide/vscode-odoo)

---

## 🧱 Clone the Repository
```bash
git clone https://github.com/waltherB/odoo-podman.git
cd odoo-podman
```

---

## ⚙️ Start the Podman Environment
Start all containers using `podman-compose`:
```bash
podman-compose up -d
```
Or use the setup script:
```bash
./setup.sh start
```

---

## 🛠 Open the Project in VS Code
```bash
code odoo-podman/
```

---

## 🧩 Install Odoo Extension for VS Code
Install the [vscode-odoo](https://github.com/odoo-ide/vscode-odoo) extension:
1. Open the Extensions panel (`Ctrl+Shift+X`).
2. Search for `@id:odoo-ide.vscode-odoo` or "Odoo".
3. Click **Install**.

This provides Odoo manifest validation, snippets, and navigation for XML, Python, and views.

---

## 🧠 Configure Python Environment

### Create a virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install pylint-odoo debugpy ruff
```

### VS Code settings (`.vscode/settings.json`):
```json
{
  "python.pythonPath": ".venv/bin/python",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.linting.pylintArgs": ["--load-plugins=pylint_odoo"],
  "python.formatting.provider": "black",
  "editor.formatOnSave": true
}
```

---

## 🐞 Debugging Odoo with VS Code + debugpy

### Add `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Attach to Odoo in Podman",
      "type": "python",
      "request": "attach",
      "connect": {
        "host": "localhost",
        "port": 5678
      },
      "pathMappings": [
        {
          "localRoot": "${workspaceFolder}",
          "remoteRoot": "/opt/odoo"
        }
      ]
    }
  ]
}
```

---

## 🧪 Automate debugpy in Container

Create `start-debugpy.sh`:
```bash
#!/bin/bash
pip install debugpy
exec python3 -m debugpy --listen 0.0.0.0:5678 --wait-for-client odoo-bin -c /etc/odoo/odoo.conf
```

Make it executable:
```bash
chmod +x start-debugpy.sh
```

**Add it to your Docker image:**
1. In your `Dockerfile`, add:
   ```dockerfile
   COPY start-debugpy.sh /start-debugpy.sh
   RUN chmod +x /start-debugpy.sh
   ```
2. Rebuild your image:
   ```bash
   ./setup.sh rebuild
   ```

Then update `docker-compose.yaml`:
```yaml
command: ["/start-debugpy.sh"]
```

---

## 🧼 Stop the Environment
```bash
podman-compose down
```
Or use the setup script:
```bash
./setup.sh delete
```

---

## 🧪 Optional: Dev Containers Support

Create `.devcontainer/devcontainer.json`:
```json
{
  "name": "Odoo Dev (Podman)",
  "context": "..",
  "dockerFile": "../Dockerfile",
  "workspaceFolder": "/opt/odoo",
  "runArgs": ["--network", "host"],
  "mounts": [
    "source=${localWorkspaceFolder}/addons,target=/opt/odoo/custom-addons,type=bind,consistency=cached"
  ],
  "settings": {
    "python.pythonPath": "/usr/bin/python3"
  },
  "extensions": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "odoo-ide.vscode-odoo"
  ],
  "postCreateCommand": "pip install -r requirements.txt"
}
```

---

## 📚 Resources
- [odoo-podman](https://github.com/waltherB/odoo-podman)
- [VS Code Python Docs](https://code.visualstudio.com/docs/python/python-tutorial)
- [Odoo VS Code Extension](https://github.com/odoo-ide/vscode-odoo) 