# LayerDiffuse Alpha API - Runpod Serverless Deployment

## What This Does

This API generates PNG images with **transparent backgrounds** from text prompts using AI.

**Input:** `"a red apple"`  
**Output:** URL to a PNG image with transparent background

---

## How It Works

```
POST /alpha/v1/txt2img  →  Returns { url, filename }
GET  /alpha/v1/file/{filename}  →  Serves the PNG image
```

---

## Quick Start (Pre-Built Image Available)

A ready-to-use Docker image is available. You can skip building and go directly to deployment.

**Docker Image:** `docker.io/igabhix001/layerdiffuse-alpha:latest`

---

## Step 1: Create Runpod Account

1. Go to https://runpod.io
2. Sign up for an account
3. Add credits ($10-20 minimum)

---

## Step 2: Create Serverless Endpoint

1. Go to https://www.runpod.io/console/serverless
2. Click **"New Endpoint"**
3. Click **"Import from Docker Registry"**
4. Enter the image: `docker.io/igabhix001/layerdiffuse-alpha:latest`
5. Click **"Next"**
6. Configure endpoint:
   - **Name:** LayerDiffuse Alpha API
   - **Endpoint Type:** Queue
   - **GPU Configuration:** See GPU Selection Guide below
   - **Max Workers:** 1 (increase for more concurrent requests)
   - **Idle Timeout:** 5 seconds
7. Click **"Deploy Endpoint"**

---

##  GPU Selection Guide (Critical for Speed)

**Generation speed depends entirely on GPU choice.** Select the right GPU for your performance needs:

| GPU | VRAM | Generation Time | Cost/hr | Best For |
|-----|------|-----------------|---------|----------|
| **H100 (80GB)** | 80 GB | **2-4 seconds** | ~$2.79 |  Production/Commercial |
| **A100 (80GB)** | 80 GB | **4-6 seconds** | ~$1.74 | Production workloads |
| **A100 (40GB)** | 40 GB | **5-8 seconds** | ~$1.29 | High-performance |
| **L40S** | 48 GB | **6-10 seconds** | ~$1.14 | Balanced performance |
| **RTX 4090** | 24 GB | **10-15 seconds** | ~$0.69 | Cost-effective |
| **RTX 3090** | 24 GB | **15-25 seconds** | ~$0.44 | Budget option |
| **A5000** | 24 GB | **20-30 seconds** | ~$0.36 | Entry level |

###  For Commercial/Production Use (Under 5 seconds)

**Recommended: NVIDIA H100 (80GB)**
- Generation time: **2-4 seconds**
- 3x faster than A100, 6x faster than RTX 4090
- 80GB HBM3 memory with 3.35 TB/s bandwidth
- Best price-to-performance for high-volume production

**Alternative: NVIDIA A100 (80GB)**
- Generation time: **4-6 seconds**
- Excellent for production workloads
- More widely available than H100

###  Why H100/A100 Are Faster

1. **Higher Memory Bandwidth:** H100 has 3.35 TB/s vs RTX 4090's 1 TB/s
2. **More Tensor Cores:** Optimized for AI inference
3. **Larger VRAM:** No memory bottlenecks with SDXL + LayerDiffuse
4. **Better FP16 Performance:** Native half-precision acceleration

---

## Step 3: Get Your API Credentials

After deployment:
1. Copy your **Endpoint ID** (looks like: `abc123xyz`)
2. Go to **Settings** → **API Keys**
3. Create or copy your **API Key**

---

## Step 4: Test Your API

### Using curl (Linux/Mac)

```bash
curl -X POST "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "prompt": "a red apple, high quality"
    }
  }'
```

### Using PowerShell (Windows)

```powershell
$headers = @{
    "Authorization" = "Bearer YOUR_API_KEY"
    "Content-Type" = "application/json"
}
$body = @{
    input = @{
        prompt = "a red apple, high quality"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" -Method POST -Headers $headers -Body $body
```

---

## Expected Response

```json
{
  "delayTime": 15000,
  "executionTime": 25000,
  "id": "job-id-here",
  "output": {
    "status": "success",
    "url": "data:image/png;base64,iVBORw0KGgo...",
    "filename": "alpha_1234567890_abc123.png",
    "image_base64": "iVBORw0KGgo...",
    "info": "generation metadata"
  },
  "status": "COMPLETED"
}
```

---

## Step 5: Use Your Image

The response contains:
- **`url`**: A data URL you can use directly in HTML `<img src="...">`
- **`image_base64`**: Raw base64 to save as a file

### Save to File (Python)
```python
import base64

image_base64 = response["output"]["image_base64"]
with open("output.png", "wb") as f:
    f.write(base64.b64decode(image_base64))
```

### Save to File (JavaScript/Node.js)
```javascript
const fs = require('fs');
const imageBase64 = response.output.image_base64;
fs.writeFileSync('output.png', Buffer.from(imageBase64, 'base64'));
```

### Use in HTML
```html
<img src="${response.output.url}" alt="Generated image">
```

---

## API Reference

### Endpoint URL
```
POST https://api.runpod.ai/v2/{ENDPOINT_ID}/runsync
```

### Headers
| Header | Value |
|--------|-------|
| `Authorization` | `Bearer YOUR_API_KEY` |
| `Content-Type` | `application/json` |

### Request Body (Minimal)
```json
{
  "input": {
    "prompt": "your text prompt here"
  }
}
```

### Request Body (Full Configuration)
```json
{
  "input": {
    "prompt": "a red apple on a wooden table, high quality, detailed",
    "negative_prompt": "bad, ugly, blurry, low quality",
    "seed": 12345,
    "steps": 30,
    "sampler_name": "Euler a",
    "scheduler": "Karras",
    "cfg_scale": 7.0,
    "width": 1024,
    "height": 1024,
    "batch_size": 1,
    "n_iter": 1,
    "restore_faces": false,
    "tiling": false,
    "subseed": -1,
    "subseed_strength": 0,
    "seed_resize_from_h": -1,
    "seed_resize_from_w": -1,
    "eta": null,
    "s_churn": 0,
    "s_tmax": null,
    "s_tmin": 0,
    "s_noise": 1,
    "override_settings": {},
    "refiner_checkpoint": null,
    "refiner_switch_at": null
  }
}
```

### All Supported Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prompt` | string | **Yes** | - | Text description of what to generate |
| `negative_prompt` | string | No | "bad, ugly" | What to avoid in the image |
| `seed` | integer | No | 12345 | Seed for reproducible results (-1 for random) |
| `steps` | integer | No | 20 | Number of sampling steps (higher = better quality, slower) |
| `sampler_name` | string | No | "DPM++ 2M SDE" | Sampler algorithm (see list below) |
| `scheduler` | string | No | "Karras" | Noise schedule (Karras, Exponential, etc.) |
| `cfg_scale` | float | No | 5.0 | Classifier Free Guidance scale (how closely to follow prompt) |
| `width` | integer | No | 1024 | Image width in pixels (must be multiple of 8) |
| `height` | integer | No | 1024 | Image height in pixels (must be multiple of 8) |
| `batch_size` | integer | No | 1 | Number of images to generate per request |
| `n_iter` | integer | No | 1 | Number of iterations (total images = batch_size × n_iter) |
| `restore_faces` | boolean | No | false | Apply face restoration |
| `tiling` | boolean | No | false | Generate tileable/seamless images |
| `subseed` | integer | No | -1 | Subseed for variation |
| `subseed_strength` | float | No | 0 | Subseed strength (0-1) |
| `seed_resize_from_h` | integer | No | -1 | Seed resize from height |
| `seed_resize_from_w` | integer | No | -1 | Seed resize from width |
| `eta` | float | No | null | Eta for ancestral samplers |
| `s_churn` | float | No | 0 | Stochastic churn |
| `s_tmax` | float | No | null | Stochastic tmax |
| `s_tmin` | float | No | 0 | Stochastic tmin |
| `s_noise` | float | No | 1 | Stochastic noise |
| `override_settings` | object | No | {} | Override model settings |
| `refiner_checkpoint` | string | No | null | Refiner model checkpoint |
| `refiner_switch_at` | float | No | null | When to switch to refiner (0-1) |

### Available Samplers
- `Euler`
- `Euler a`
- `LMS`
- `Heun`
- `DPM2`
- `DPM2 a`
- `DPM++ 2S a`
- `DPM++ 2M`
- `DPM++ 2M SDE` (default)
- `DPM++ 2M SDE Heun`
- `DPM++ 3M SDE`
- `DPM fast`
- `DPM adaptive`
- `LMS Karras`
- `DPM2 Karras`
- `DPM2 a Karras`
- `DPM++ 2S a Karras`
- `DPM++ 2M Karras`
- `DPM++ 2M SDE Karras`
- `DPM++ 3M SDE Karras`
- `DDIM`
- `PLMS`
- `UniPC`

### Available Schedulers
- `Karras` (default)
- `Exponential`
- `Polyexponential`
- `SGM Uniform`
- `Simple`
- `Normal`
- `DDIM`
- `Automatic`

### Response
```json
{
  "status": "COMPLETED",
  "output": {
    "status": "success",
    "url": "data:image/png;base64,...",
    "filename": "alpha_xxx.png",
    "image_base64": "...",
    "info": "generation metadata"
  }
}
```

---

## Default Generation Settings

The API uses these default settings (all can be overridden):

- **Image Size:** 1024x1024 pixels
- **Steps:** 20
- **Sampler:** DPM++ 2M SDE
- **Scheduler:** Karras
- **CFG Scale:** 5
- **Seed:** 12345
- **Format:** PNG with transparency (LayerDiffuse - always enabled)

**Note:** All parameters except `prompt` are optional. If not provided, the API falls back to these defaults.

---

## Testing the API

### Test 1: Minimal Request (Defaults Only)
```bash
curl -X POST "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "prompt": "a red apple on a wooden table, high quality"
    }
  }'
```

### Test 2: Custom Parameters
```bash
curl -X POST "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "prompt": "a red apple on a wooden table, high quality",
      "negative_prompt": "bad quality, blurry, distorted",
      "seed": 42,
      "steps": 30,
      "cfg_scale": 7.5,
      "sampler_name": "Euler a"
    }
  }'
```

### Test 3: Full Configuration Override
```bash
curl -X POST "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "prompt": "a majestic dragon flying over mountains, epic fantasy art",
      "negative_prompt": "bad, ugly, blurry, low quality, deformed",
      "seed": 999,
      "steps": 40,
      "sampler_name": "DPM++ 2M Karras",
      "scheduler": "Karras",
      "cfg_scale": 8.0,
      "width": 1024,
      "height": 768,
      "batch_size": 1
    }
  }'
```

### Test 4: PowerShell (Windows)
```powershell
$headers = @{
    "Authorization" = "Bearer YOUR_API_KEY"
    "Content-Type" = "application/json"
}
$body = @{
    input = @{
        prompt = "a cute cat wearing a hat, studio photography"
        negative_prompt = "bad quality, blurry"
        seed = 12345
        steps = 25
        cfg_scale = 6.5
        sampler_name = "Euler a"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" -Method POST -Headers $headers -Body $body
```

### Test 5: Python Script
```python
import requests
import json
import base64

# API configuration
ENDPOINT_ID = "YOUR_ENDPOINT_ID"
API_KEY = "YOUR_API_KEY"
API_URL = f"https://api.runpod.ai/v2/{ENDPOINT_ID}/runsync"

# Test with custom parameters
payload = {
    "input": {
        "prompt": "a beautiful sunset over the ocean, vibrant colors",
        "negative_prompt": "bad quality, blurry, dark",
        "seed": 777,
        "steps": 35,
        "cfg_scale": 7.0,
        "sampler_name": "DPM++ 2M SDE Karras",
        "width": 1024,
        "height": 1024
    }
}

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Make request
response = requests.post(API_URL, json=payload, headers=headers)
result = response.json()

# Save the image
if result["status"] == "COMPLETED":
    image_base64 = result["output"]["image_base64"]
    with open("output.png", "wb") as f:
        f.write(base64.b64decode(image_base64))
    print(f"Image saved: {result['output']['filename']}")
else:
    print(f"Error: {result}")
```

---

## Pricing

Pricing varies by GPU tier:

| GPU | Cost/second | Cost per image |
|-----|-------------|----------------|
| H100 (80GB) | $0.00078 | ~$0.002-0.003 (2-4 sec) |
| A100 (80GB) | $0.00048 | ~$0.002-0.003 (4-6 sec) |
| A100 (40GB) | $0.00036 | ~$0.002-0.003 (5-8 sec) |
| L40S | $0.00032 | ~$0.002-0.003 (6-10 sec) |
| RTX 4090 | $0.00019 | ~$0.002-0.003 (10-15 sec) |

**Key insight:** Faster GPUs cost more per second but generate images faster, resulting in **similar cost per image** across all tiers. Choose based on **speed requirements**, not cost.

---

## Cold Start Warning

The **first request after idle** takes **2-5 minutes** (cold start) to load the model into GPU memory.

**Subsequent requests are fast** (see GPU table above for times).

### Eliminating Cold Starts

| Strategy | Cold Start | Cost When Idle |
|----------|------------|----------------|
| Min Workers = 0 | 2-5 minutes | $0 |
| Min Workers = 1 | **None** | GPU hourly rate |

**For production:** Set **Min Workers = 1** to keep a worker always warm. This eliminates cold starts entirely.

---

## 🚀 Optimization Tips for Maximum Speed

### 1. Use H100 or A100 GPUs
The single biggest factor in generation speed. H100 delivers **2-4 second** generation.

### 2. Set Min Workers = 1
Eliminates cold start delays. Worker stays warm and ready.

### 3. Use Active Workers (Not Flex)
Active workers have priority scheduling and faster response times.

### 4. Deploy in Optimal Region
Choose a region close to your users for lower network latency.

### 5. Use Async Requests for Batches
For multiple images, use `/run` endpoint instead of `/runsync` to queue jobs in parallel.

---

## Troubleshooting

### Problem: Request times out
**Solution:** First request has a cold start. Wait 2-5 minutes and check status.

### Problem: "CUDA out of memory"
**Solution:** Select a GPU with more VRAM (A100 80GB or H100 recommended).

### Problem: Status shows "FAILED"
**Solution:** Check the error message in the response. Common issues:
- Missing prompt
- Invalid JSON format

---

## Support

If you encounter issues:
1. Check the Runpod logs for your endpoint
2. Verify your API key is correct
3. Ensure you selected a 24GB GPU
4. Check that the request JSON is valid

---

*This API is pay-per-use. You are only charged when generating images.*
