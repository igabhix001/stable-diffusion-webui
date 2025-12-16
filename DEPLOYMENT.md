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
   - **GPU Configuration:** Check **24 GB** (RTX 4090/3090/A5000)
   - **Max Workers:** 1 (increase for more concurrent requests)
   - **Idle Timeout:** 5 seconds
7. Click **"Deploy Endpoint"**

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

### Request Body
```json
{
  "input": {
    "prompt": "your text prompt here",
    "negative_prompt": "bad, ugly",
    "seed": 12345
  }
}
```

### Parameters
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `prompt` | Yes | - | What you want to generate |
| `negative_prompt` | No | "bad, ugly" | What to avoid |
| `seed` | No | random | Number for reproducible results |

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

## Fixed Generation Settings

The API uses these optimized settings:

- **Image Size:** 1024x1024 pixels
- **Steps:** 20
- **Sampler:** DPM++ 2M SDE Karras
- **CFG Scale:** 5
- **Format:** PNG with transparency (LayerDiffuse)

---

## Pricing

- **You only pay when the API is used**
- **$0 when idle** - no charges when not in use
- Typical cost: ~$0.0004 per second of GPU time
- One image (~20-30 seconds): ~$0.008-0.012

---

## Cold Start Warning

The **first request after idle** may take **2-5 minutes** (cold start) as the worker loads the model.

Subsequent requests are fast (~20-30 seconds).

To reduce cold starts:
- Set **Min Workers** to 1 (keeps one worker always ready, but costs money when idle)
- Or accept the cold start delay for maximum cost savings

---

## Troubleshooting

### Problem: Request times out
**Solution:** First request has a cold start. Wait 2-5 minutes and check status.

### Problem: "CUDA out of memory"
**Solution:** Select a GPU with 24GB VRAM (RTX 4090/3090/A5000).

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
