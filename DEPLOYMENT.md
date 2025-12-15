# LayerDiffuse Alpha API - Deployment Documentation

## Overview

This API provides a simple endpoint for generating PNG images with transparent backgrounds using Stable Diffusion XL and the LayerDiffuse extension.

**API Endpoint:** `POST /alpha/v1/txt2img`

**Input:** Text prompt  
**Output:** URL to generated PNG with alpha transparency

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Quick Start (Local)](#quick-start-local)
3. [API Reference](#api-reference)
4. [Runpod Deployment](#runpod-deployment)
5. [Configuration](#configuration)
6. [Scaling for Multiple Users](#scaling-for-multiple-users)
7. [Troubleshooting](#troubleshooting)
8. [Licensing](#licensing)

---

## System Requirements

### Hardware
- **GPU:** NVIDIA GPU with 12GB+ VRAM (RTX 3080/4080 or better recommended)
- **RAM:** 16GB+ system memory
- **Storage:** 20GB+ for models and outputs

### Software
- **OS:** Windows 10/11, Linux (Ubuntu 20.04+)
- **Python:** 3.10.x
- **CUDA:** 11.8 or 12.1
- **Git:** Latest version

---

## Quick Start (Local)

### 1. Clone and Setup

```bash
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git
cd stable-diffusion-webui-forge
```

### 2. Install Dependencies

**Windows:**
```powershell
.\webui.bat
# Wait for initial setup to complete, then close
```

**Linux:**
```bash
./webui.sh
# Wait for initial setup to complete, then close
```

### 3. Download Required Model

Download **Juggernaut XL v6** (or any SDXL model) and place in:
```
models/Stable-diffusion/
```

### 4. Install LayerDiffuse Extension

```bash
cd extensions
git clone https://github.com/layerdiffusion/sd-forge-layerdiffuse.git
cd ..
```

### 5. Start API Server

**Windows (PowerShell):**
```powershell
.\venv\Scripts\python.exe launch.py --nowebui --api
```

**Linux:**
```bash
./venv/bin/python launch.py --nowebui --api
```

The API will be available at: `http://127.0.0.1:7861`

### 6. Verify Installation

Open in browser: `http://127.0.0.1:7861/docs`

You should see the Swagger API documentation with `/alpha/v1/txt2img` endpoint listed.

---

## API Reference

### Generate Image

**Endpoint:** `POST /alpha/v1/txt2img`

**Request Body:**
```json
{
  "prompt": "an apple, high quality",
  "negative_prompt": "bad, ugly",
  "seed": 12345
}
```

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prompt` | string | ✅ Yes | - | Text description of the image |
| `negative_prompt` | string | No | "bad, ugly" | What to avoid in generation |
| `seed` | integer | No | 12345 | Random seed for reproducibility |

**Response:**
```json
{
  "url": "http://127.0.0.1:7861/alpha/v1/file/alpha_1702500000_abc123.png",
  "filename": "alpha_1702500000_abc123.png",
  "info": "{\"prompt\": \"an apple, high quality\", ...}"
}
```

### Retrieve Image

**Endpoint:** `GET /alpha/v1/file/{filename}`

Returns the PNG image file directly.

---

## API Usage Examples

### cURL (Linux/Mac)

```bash
curl -X POST "http://YOUR_SERVER:7861/alpha/v1/txt2img" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "a red apple on white background, high quality"}'
```

### PowerShell (Windows)

```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:7861/alpha/v1/txt2img" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"prompt": "a red apple on white background, high quality"}'
```

### Python

```python
import requests

response = requests.post(
    "http://YOUR_SERVER:7861/alpha/v1/txt2img",
    json={"prompt": "a red apple on white background, high quality"}
)

data = response.json()
print(f"Image URL: {data['url']}")

# Download the image
img_response = requests.get(data['url'])
with open("output.png", "wb") as f:
    f.write(img_response.content)
```

### JavaScript/Node.js

```javascript
const response = await fetch("http://YOUR_SERVER:7861/alpha/v1/txt2img", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ prompt: "a red apple on white background, high quality" })
});

const data = await response.json();
console.log("Image URL:", data.url);
```

---

## Runpod Deployment

### Option A: Using Runpod Template (Recommended)

1. **Create a Runpod Account** at https://runpod.io

2. **Deploy a GPU Pod:**
   - Select GPU: RTX 4090 (24GB) or A5000 (24GB)
   - Template: PyTorch 2.0 / CUDA 11.8
   - Container Disk: 50GB
   - Volume Disk: 50GB (for models)

3. **Connect via SSH/Terminal**

4. **Clone Repository:**
   ```bash
   cd /workspace
   git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git
   cd stable-diffusion-webui-forge
   ```

5. **Run Initial Setup:**
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements_versions.txt
   ```

6. **Download Model:**
   ```bash
   cd models/Stable-diffusion
   wget "YOUR_MODEL_URL" -O juggernautXL_v6.safetensors
   cd ../..
   ```

7. **Install LayerDiffuse:**
   ```bash
   cd extensions
   git clone https://github.com/layerdiffusion/sd-forge-layerdiffuse.git
   cd ..
   ```

8. **Start API Server:**
   ```bash
   python launch.py --nowebui --api --listen --port 7861
   ```

9. **Expose Port:**
   - In Runpod dashboard, go to "Connect"
   - Add TCP port 7861
   - Use the provided public URL

### Option B: Using Docker

```dockerfile
# Dockerfile
FROM pytorch/pytorch:2.0.1-cuda11.8-cudnn8-runtime

WORKDIR /app

RUN apt-get update && apt-get install -y git wget

RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git .

RUN pip install -r requirements_versions.txt

# Install LayerDiffuse
RUN cd extensions && git clone https://github.com/layerdiffusion/sd-forge-layerdiffuse.git

EXPOSE 7861

CMD ["python", "launch.py", "--nowebui", "--api", "--listen", "--port", "7861"]
```

---

## Configuration

### Fixed Generation Parameters

The API uses these optimized defaults:

| Parameter | Value |
|-----------|-------|
| Steps | 20 |
| Sampler | DPM++ 2M SDE |
| Scheduler | Karras |
| CFG Scale | 5 |
| Width | 1024 |
| Height | 1024 |
| LayerDiffuse | Attention Injection (SDXL) |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `COMMANDLINE_ARGS` | CLI arguments | - |
| `CUDA_VISIBLE_DEVICES` | GPU selection | 0 |

### Command Line Arguments

| Argument | Description |
|----------|-------------|
| `--nowebui` | API-only mode (no Gradio UI) |
| `--api` | Enable API endpoints |
| `--listen` | Listen on all interfaces (0.0.0.0) |
| `--port 7861` | Custom port |
| `--cors-allow-origins "*"` | Enable CORS for all origins |

---

## Scaling for Multiple Users

### Current Architecture

```
[Client] → [API Server] → [GPU Queue] → [Response]
```

- Requests are processed sequentially
- Each image takes ~15-30 seconds
- Queue handles concurrent requests

### Scaling Options

#### Option 1: Single Pod (Up to 5 concurrent users)
- Users experience queue wait times
- Simple setup, lowest cost

#### Option 2: Multiple Pods with Load Balancer (20+ users)

```
                    ┌─→ [Pod 1 - GPU]
[Client] → [Nginx] ─┼─→ [Pod 2 - GPU]
                    ├─→ [Pod 3 - GPU]
                    └─→ [Pod 4 - GPU]
```

**Nginx Configuration:**
```nginx
upstream forge_api {
    least_conn;
    server pod1.runpod.io:7861;
    server pod2.runpod.io:7861;
    server pod3.runpod.io:7861;
    server pod4.runpod.io:7861;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://forge_api;
        proxy_read_timeout 120s;
    }
}
```

#### Option 3: Runpod Serverless (Auto-scaling)

Runpod offers serverless GPU endpoints that auto-scale based on demand. This is ideal for variable traffic.

### Capacity Planning

| Pods | Concurrent Users | Avg Wait Time |
|------|------------------|---------------|
| 1 | 5 | 60-90s |
| 2 | 10 | 30-45s |
| 4 | 20 | 15-30s |
| 8 | 40 | <15s |

---

## Troubleshooting

### Common Issues

#### 1. "CUDA out of memory"
- **Cause:** GPU VRAM insufficient
- **Fix:** Use a GPU with 12GB+ VRAM, or reduce image size

#### 2. "Model not found"
- **Cause:** SDXL model not in correct directory
- **Fix:** Place `.safetensors` file in `models/Stable-diffusion/`

#### 3. "LayerDiffuse not working"
- **Cause:** Extension not installed or incompatible
- **Fix:** 
  ```bash
  cd extensions
  rm -rf sd-forge-layerdiffuse
  git clone https://github.com/layerdiffusion/sd-forge-layerdiffuse.git
  ```

#### 4. "Connection refused"
- **Cause:** Server not running or wrong port
- **Fix:** Ensure `--listen` flag is used for remote access

#### 5. "API returns 500 error"
- **Cause:** Various (check server logs)
- **Fix:** Check terminal output for detailed error message

### Health Check

```bash
curl http://YOUR_SERVER:7861/sdapi/v1/sd-models
```

Should return list of available models.

---

## Licensing

### Components and Licenses

| Component | License | Commercial Use |
|-----------|---------|----------------|
| Stable Diffusion WebUI Forge | AGPL-3.0 | ✅ Yes* |
| LayerDiffuse | Apache-2.0 | ✅ Yes |
| SDXL Base Model | CreativeML Open RAIL++-M | ✅ Yes** |
| Juggernaut XL | CreativeML Open RAIL++-M | ✅ Yes** |
| FastAPI | MIT | ✅ Yes |
| PyTorch | BSD-3 | ✅ Yes |

**\* AGPL-3.0 Note:** If you modify the Forge code and provide it as a network service, you must make your modifications available under AGPL-3.0.

**\*\* Model License Restrictions:**
- Cannot use for illegal content
- Cannot use for deepfakes without consent
- Cannot claim model as proprietary
- Generated images can be used commercially

### Summary

✅ **You CAN:**
- Use this system for commercial projects
- Charge customers for generated images
- Deploy on your own infrastructure
- Modify the code for your needs

⚠️ **You MUST:**
- Share code modifications if distributing as a service (AGPL-3.0)
- Comply with model usage restrictions
- Not generate prohibited content

---

## Support

For issues with:
- **Forge:** https://github.com/lllyasviel/stable-diffusion-webui-forge/issues
- **LayerDiffuse:** https://github.com/layerdiffusion/sd-forge-layerdiffuse/issues

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-12 | Initial release with `/alpha/v1/txt2img` endpoint |

---

*Documentation generated for LayerDiffuse Alpha API*
