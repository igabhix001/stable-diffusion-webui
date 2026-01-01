# LayerDiffuse Alpha API - Transparent PNG Generation

## Overview

This API generates **high-quality PNG images with transparent backgrounds** from text prompts using Stable Diffusion XL with LayerDiffuse extension.

**Key Features:**
-  **Always Transparent:** Every image has alpha channel (transparent background)
-  **Multiple Generator Types:** General, Aesthetic, Logo, 3D Icon presets
-  **LoRA Support:** Add any SDXL-compatible LoRA for custom styles
-  **Full Parameter Control:** Override any default setting
-  **Production Ready:** Fast generation with JuggernautXL v9

**Input:** `"a red apple"`  
**Output:** PNG image with transparent background + metadata

---

## How It Works

```
POST /alpha/v1/txt2img
  
Generate with JuggernautXL v9 + LayerDiffuse
  
Returns { url, filename, image_base64, info }
```

**Base Model:** JuggernautXL v9 (photorealistic, high aesthetic quality)  
**Extension:** LayerDiffuse (forced transparent background)  
**LoRAs Available:** geometric-logo, 3d-icon-lora (+ any SDXL LoRA you add)

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
2. Go to **Settings**  **API Keys**
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
| `n_iter` | integer | No | 1 | Number of iterations (total images = batch_size  n_iter) |
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
| `generator_type` | string | No | "general" | Generator preset: "general", "aesthetic", "logo", "icon_3d" |
| `checkpoint` | string | No | null | Explicit checkpoint name (overrides generator_type) |
| `loras` | array | No | null | List of LoRAs: `[{"name": "lora_name", "weight": 0.8}]` |

---

## Generator Types (Presets)

The API supports 5 generator presets optimized for different use cases. **LayerDiffuse is enabled by default** for transparent PNG backgrounds (can be overridden).

| Generator Type | Checkpoint | LoRAs | Trigger Words | Best For |
|----------------|------------|-------|---------------|----------|
| `general` | JuggernautXL v9 | None | - | Realistic images, general purpose |
| `general_v6` | JuggernautXL v6 | None | - | Legacy v6 checkpoint |
| `aesthetic` | JuggernautXL v9 | None | - | High quality, enhanced prompts |
| `logo` | JuggernautXL v9 | geometric-logo (0.85) | `flat-line-logo, geometric` | Geometric/minimal logos |
| `icon_3d` | JuggernautXL v9 | 3d-icon-lora (0.85) | `<s0><s1>` | 3D glossy icons |

### Important Notes
- **LayerDiffuse enabled by default** - can be disabled with `layerdiffuse_enabled: false`
- **Trigger words are auto-added** when using presets (logo/icon_3d)
- **JuggernautXL v9** is default, v6 available via `general_v6` preset
- **All LayerDiffuse parameters can be overridden** - see LayerDiffuse section below
- You can override checkpoint/LoRAs with custom values

### Example 1: General Preset (Realistic)
```json
{
  "input": {
    "prompt": "a red apple on wooden table, photorealistic",
    "generator_type": "general"
  }
}
```
**Output:** Realistic apple image with transparent background

### Example 2: Aesthetic Preset (Enhanced Quality)
```json
{
  "input": {
    "prompt": "beautiful sunset over mountains, vibrant colors",
    "generator_type": "aesthetic",
    "steps": 30,
    "cfg_scale": 7.0
  }
}
```
**Output:** High-quality sunset with prompt enhancement: "high quality, detailed, masterpiece, best quality, beautiful sunset..."

### Example 3: Logo Preset (Geometric LoRA)
```json
{
  "input": {
    "prompt": "minimalist fox logo, orange and white, simple",
    "generator_type": "logo"
  }
}
```
**Output:** Geometric logo with auto-added trigger words: "flat-line-logo, geometric, minimalist fox logo..."

### Example 4: 3D Icon Preset (3D LoRA)
```json
{
  "input": {
    "prompt": "shopping cart icon, glossy, colorful",
    "generator_type": "icon_3d",
    "steps": 25
  }
}
```
**Output:** 3D glossy icon with auto-added trigger: "<s0><s1> shopping cart icon..."

### Example 5: Custom LoRA Override
```json
{
  "input": {
    "prompt": "geometric wolf logo, blue and silver",
    "checkpoint": "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors",
    "loras": [
      {"name": "geometric-logo", "weight": 0.95}
    ]
  }
}
```
**Output:** Custom LoRA weight (0.95) without auto-added trigger words

### Example 6: Add Your Own SDXL LoRA
```json
{
  "input": {
    "prompt": "cyberpunk city, neon lights",
    "loras": [
      {"name": "your-custom-lora", "weight": 0.8}
    ]
  }
}
```
**Note:** Place your `.safetensors` LoRA file in `models/Lora/` folder and use filename (without extension) as name

---

## Available Models

### Base Checkpoints

| Checkpoint Name | Description | Use Case |
|-----------------|-------------|----------|
| `Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors` | JuggernautXL v9 - High quality, photorealistic, excellent prompt adherence | Default for all presets |
| `juggernautXL_version6Rundiffusion.safetensors` | JuggernautXL v6 - Legacy version, general purpose | Use with `general_v6` preset |

**Note:** Both v6 and v9 are included. v9 is recommended for best quality.

### Built-in LoRAs

| LoRA Name | Trigger Words | Weight Range | Description |
|-----------|---------------|--------------|-------------|
| `geometric-logo` | `flat-line-logo, geometric` | 0.7-0.95 | Geometric/minimal logo designs with flat lines |
| `3d-icon-lora` | `<s0><s1>` | 0.7-0.95 | 3D glossy icon style |

### Adding Custom SDXL LoRAs

**Any SDXL-compatible LoRA** can be used with this API:

1. **Place LoRA file** in Docker: `models/Lora/your-lora-name.safetensors`
2. **Use in API** with filename (no extension):
   ```json
   {
     "loras": [{"name": "your-lora-name", "weight": 0.8}]
   }
   ```
3. **Add trigger words** to your prompt if the LoRA requires them

**Example LoRA sources:**
- Civitai.com (filter by SDXL)
- HuggingFace (search "SDXL LoRA")
- Ensure LoRA is trained on SDXL base (not SD1.5 or Flux)

---

## LayerDiffuse Extension Parameters

LayerDiffuse is **enabled by default** to generate transparent PNG backgrounds. All parameters can be overridden:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `layerdiffuse_enabled` | boolean | `true` | Enable/disable LayerDiffuse extension |
| `layerdiffuse_method` | string | `"(SDXL) Only Generate Transparent Image (Attention Injection)"` | LayerDiffuse generation method |
| `layerdiffuse_weight` | float | `1.0` | LayerDiffuse effect strength (0.0-2.0) |
| `layerdiffuse_stop_at` | float | `1.0` | When to stop applying LayerDiffuse (0.0-1.0) |
| `layerdiffuse_resize_mode` | string | `"Crop and Resize"` | How to handle image resizing |
| `layerdiffuse_output_origin` | boolean | `false` | Output original image alongside transparent |

### Available LayerDiffuse Methods
- `(SDXL) Only Generate Transparent Image (Attention Injection)` - Default, best quality
- Other SDXL LayerDiffuse methods supported by the extension

### Example: Disable Transparency
```json
{
  "input": {
    "prompt": "beautiful sunset over mountains",
    "layerdiffuse_enabled": false
  }
}
```

### Example: Adjust LayerDiffuse Strength
```json
{
  "input": {
    "prompt": "product photo of a watch",
    "layerdiffuse_weight": 0.8,
    "layerdiffuse_stop_at": 0.9
  }
}
```

---

## Complete Parameter Reference

### Available Samplers

**Fast Samplers (15-25 steps recommended):**
- `DPM++ 2M SDE`  **Default** - Best quality/speed balance
- `DPM++ 2M Karras` - High quality, slightly slower
- `Euler a` - Fast, good for creative variations
- `DPM++ 2M` - Consistent results

**Quality Samplers (25-40 steps recommended):**
- `DPM++ 3M SDE` - Highest quality, slower
- `DPM++ 2M SDE Heun` - Very high quality
- `UniPC` - Good detail preservation

**Other Samplers:**
- `Euler` - Simple, fast
- `LMS` - Legacy sampler
- `Heun` - High quality, slow
- `DPM2`, `DPM2 a` - Older DPM variants
- `DPM++ 2S a` - Alternative DPM
- `DPM fast`, `DPM adaptive` - Experimental
- `LMS Karras`, `DPM2 Karras`, `DPM2 a Karras`, `DPM++ 2S a Karras`, `DPM++ 3M SDE Karras` - Karras noise schedule variants
- `DDIM`, `PLMS` - Legacy samplers

**Recommendation:** Use `DPM++ 2M SDE` (default) with 20-25 steps for best results.

### Available Schedulers

| Scheduler | Description | Best For |
|-----------|-------------|----------|
| `Karras`  | **Default** - Improved noise schedule | General use, best quality |
| `Exponential` | Exponential noise decay | Smooth transitions |
| `Polyexponential` | Polynomial exponential | Alternative to Exponential |
| `SGM Uniform` | Uniform noise distribution | Experimental |
| `Simple` | Simple linear schedule | Basic generations |
| `Normal` | Standard schedule | Legacy compatibility |
| `DDIM` | DDIM-specific schedule | When using DDIM sampler |
| `Automatic` | Auto-select based on sampler | Let system decide |

**Recommendation:** Use `Karras` (default) for best results with most samplers.

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

The API uses these default settings. **Every parameter can be overridden** by including it in your request:

| Parameter | Default Value | Override Example |
|-----------|---------------|------------------|
| **Image Size** | 10241024 | `"width": 768, "height": 1024` |
| **Steps** | 20 | `"steps": 30` |
| **Sampler** | DPM++ 2M SDE | `"sampler_name": "Euler a"` |
| **Scheduler** | Karras | `"scheduler": "Exponential"` |
| **CFG Scale** | 5.0 | `"cfg_scale": 7.5` |
| **Seed** | 12345 | `"seed": -1` (random) |
| **Negative Prompt** | "bad, ugly" | `"negative_prompt": "your custom negative"` |
| **Batch Size** | 1 | `"batch_size": 4` |
| **Format** | PNG + Alpha | **Cannot be changed** (LayerDiffuse always enabled) |

### Important Notes

 **All parameters are optional** except `prompt`  
 **Any default can be overridden** by specifying it in your request  
 **LayerDiffuse is ALWAYS enabled** - transparent background is guaranteed  
 **Seed = -1** generates random seed each time  
 **Higher steps** = better quality but slower (20-30 recommended)  
 **CFG Scale 5-8** works best (higher = follows prompt more strictly)

---

## Testing the API

### Test 1: Fox Cartoon  



```bash
curl -X POST "http://127.0.0.1:7860/alpha/v1/txt2img" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "cute cartoon fox mascot standing, full body, hands on hips, clean outlines, flat shading, vibrant white background, vector style, simple shapes, minimal design, pop icon style, simple, flat-line-logo",
    "negative_prompt": "blurry, low quality, lowres, cropped, links, deformed, distorted, bad anatomy, oversaturated, noisy, jpeg artifacts, watermark, text, logo",
    "seed": 12346,
    "steps": 20,
    "sampler_name": "DPM++ 2M SDE",
    "scheduler": "Karras",
    "cfg_scale": 5,
    "width": 1024,
    "height": 1024,
    "batch_size": 1,
    "layerdiffuse_enabled": true,
    "layerdiffuse_method": "(SDXL) Only Generate Transparent Image (Attention Injection)",
    "layerdiffuse_weight": 1.0,
    "layerdiffuse_stop_at": 1.0,
    "layerdiffuse_resize_mode": "Crop and Resize",
    "layerdiffuse_output_origin": false
  }'
```

**PowerShell:**
```powershell
$body = @{
    prompt = "cute cartoon fox mascot standing, full body, hands on hips, clean outlines, flat shading, vibrant white background, vector style, simple shapes, minimal design, pop icon style, simple, flat-line-logo"
    negative_prompt = "blurry, low quality, lowres, cropped, links, deformed, distorted, bad anatomy, oversaturated, noisy, jpeg artifacts, watermark, text, logo"
    seed = 12346
    steps = 20
    sampler_name = "DPM++ 2M SDE"
    scheduler = "Karras"
    cfg_scale = 5
    width = 1024
    height = 1024
    batch_size = 1
    layerdiffuse_enabled = $true
    layerdiffuse_method = "(SDXL) Only Generate Transparent Image (Attention Injection)"
    layerdiffuse_weight = 1.0
    layerdiffuse_stop_at = 1.0
    layerdiffuse_resize_mode = "Crop and Resize"
    layerdiffuse_output_origin = $false
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://127.0.0.1:7860/alpha/v1/txt2img" -Method POST -Body $body -ContentType "application/json"
```

**Output:** Transparent PNG with cartoon fox, all UI parameters applied

### Test 2: Coffee Mug 

```bash
curl -X POST "http://127.0.0.1:7860/alpha/v1/txt2img" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "high quality studio photo of a white ceramic coffee mug with a small blue coffee logo, centered on a pure white background, soft shadows, 3 point lighting, 8k, ultra detailed, clean, minimal, product photography",
    "negative_prompt": "blurry, low quality, lowres, cropped, links, deformed, distorted, bad anatomy, oversaturated, noisy, jpeg artifacts, watermark, text, logo",
    "seed": 12346,
    "steps": 20,
    "sampler_name": "DPM++ 2M SDE",
    "scheduler": "Karras",
    "cfg_scale": 5,
    "width": 1024,
    "height": 1024,
    "layerdiffuse_enabled": false
  }'
```

**Output:** coffee mug product photo with white background


```bash
curl -X POST "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "prompt": "minimalist wolf logo, blue and white",
      "generator_type": "logo",
      "steps": 25
    }'
```
**Uses:** Logo preset (auto-adds "flat-line-logo, geometric" + geometric-logo LoRA)

### Test 4: 3D Icon with Custom Settings
```bash
curl -X POST "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "prompt": "email icon, glossy, blue gradient",
      "generator_type": "icon_3d",
      "steps": 25,
      "cfg_scale": 6.5,
      "seed": 999
    }
  }'
```
**Uses:** 3D icon preset (auto-adds "<s0><s1>" trigger + 3d-icon-lora LoRA)

### Test 5: Full Manual Control (All Parameters)
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

**Overrides:** All parameters manually set, landscape aspect ratio, high quality settings

### Test 6: PowerShell (Windows)
```powershell
$headers = @{
    "Authorization" = "Bearer YOUR_API_KEY"
    "Content-Type" = "application/json"
}
$body = @{
    input = @{
        prompt = "a cute cat wearing a hat, studio photography"
        negative_prompt = "bad quality, blurry"
        generator_type = "aesthetic"
        seed = 12345
        steps = 25
        cfg_scale = 6.5
        sampler_name = "Euler a"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync" -Method POST -Headers $headers -Body $body
```

### Test 7: Python Script
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

##  Optimization Tips for Maximum Speed

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

## Common Mistakes & Troubleshooting

###  Mistake 1: Wrong Checkpoint Name
**Problem:** Using old checkpoint names like `juggernautXL_v6.safetensors` or `playground-v2.5`  
**Solution:** Use exact name: `Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors`

**Correct:**
```json
{"checkpoint": "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"}
```

###  Mistake 2: Wrong LoRA Names
**Problem:** Using underscores instead of hyphens  
**Solution:** LoRA names must match filenames exactly:
-  `geometric-logo` (correct)
-  `geometric_logo` (wrong)
-  `3d-icon-lora` (correct)
-  `3d_icon_lora` (wrong)

###  Mistake 3: Forgetting Trigger Words
**Problem:** LoRA doesn't activate properly  
**Solution:** When using custom LoRAs (not presets), add trigger words to your prompt:
- **geometric-logo:** Add `flat-line-logo, geometric` to prompt
- **3d-icon-lora:** Add `<s0><s1>` to prompt

**Note:** Presets auto-add trigger words. Only needed when using `loras` parameter directly.

###  Mistake 4: Incompatible LoRA
**Problem:** LoRA doesn't work or causes errors  
**Solution:** Only use **SDXL-compatible LoRAs**. Check LoRA base model:
-  SDXL (works)
-  SD 1.5 (incompatible)
-  Flux (incompatible)

###  Mistake 5: Expecting Non-Transparent Output
**Problem:** Want solid background instead of transparent  
**Solution:** **Not possible.** LayerDiffuse is always enabled. Every image has transparent background. If you need solid background, add it in post-processing.

###  Mistake 6: Wrong Sampler Name
**Problem:** Typos in sampler name  
**Solution:** Use exact names from Available Samplers list:
-  `DPM++ 2M SDE` (correct)
-  `DPM++2M SDE` (wrong - missing space)
-  `Euler a` (correct)
-  `euler a` (wrong - case sensitive)

---

## Troubleshooting

### Problem: Request times out
**Solution:** First request has a cold start (2-5 minutes). Wait and check status, or set Min Workers = 1.

### Problem: "CUDA out of memory"
**Solution:** Select a GPU with more VRAM (24GB minimum). Recommended: A100 80GB or H100.

### Problem: Status shows "FAILED"
**Solution:** Check error message in response. Common issues:
- Missing `prompt` field (required)
- Invalid JSON format
- Wrong checkpoint/LoRA name (case-sensitive)
- Incompatible LoRA (must be SDXL)

### Problem: LoRA has no effect
**Solution:**
1. Verify LoRA filename matches exactly (check hyphens vs underscores)
2. Add trigger words to prompt if not using preset
3. Increase LoRA weight (try 0.9-1.0)
4. Ensure LoRA is SDXL-compatible

### Problem: Image quality is poor
**Solution:**
1. Increase steps (try 25-35)
2. Increase CFG scale (try 6.5-8.0)
3. Use better sampler: `DPM++ 2M Karras` or `DPM++ 3M SDE`
4. Add quality keywords: "high quality, detailed, masterpiece"
5. Use `aesthetic` preset for automatic quality enhancement

### Problem: Transparent background not working
**Solution:** This is impossible. LayerDiffuse is **always enabled** and **cannot be disabled**. Every image has transparent background. If you're seeing solid background:
- Check if image viewer supports transparency
- Verify PNG file has alpha channel (should be RGBA, not RGB)
- Some viewers show checkerboard pattern for transparency

---

## Support

If you encounter issues:
1. **Check Runpod logs** for your endpoint (detailed error messages)
2. **Verify API key** is correct and has credits
3. **Ensure GPU selection** is 24GB minimum (A100/H100 recommended)
4. **Validate JSON** format using online JSON validator
5. **Check parameter names** are spelled exactly as documented (case-sensitive)
6. **Review examples** in this guide and copy exact format

---

*This API is pay-per-use. You are only charged when generating images.*
