# LayerDiffuse Alpha API - Simple Deployment Guide

## What This Does

This API generates PNG images with **transparent backgrounds** from text prompts using AI. 

**Input:** `"a red apple"`  
**Output:** URL to a PNG image of a red apple with transparent background

---

## Step-by-Step Runpod Deployment

### Step 1: Create Runpod Account

1. Go to https://runpod.io
2. Sign up for an account
3. Add credits to your account ($10-20 minimum)

### Step 2: Launch a GPU Pod

1. Click **"Deploy"** → **"GPU Pods"**
2. **Choose GPU:**
   - **RTX 4090** (24GB VRAM) - Recommended
   - **RTX 3090** (24GB VRAM) - Good
   - **A5000** (24GB VRAM) - Good
   - **RTX 4080** (16GB VRAM) - Minimum
3. **Choose Template:** 
   - Select **"PyTorch 2.0"** or **"RunPod PyTorch"**
4. **Storage:**
   - Container Disk: **50GB**
   - Volume Disk: **50GB** (optional but recommended)
5. Click **"Deploy On Demand"**

### Step 3: Connect to Your Pod

1. Wait for pod to start (Status: Running)
2. Click **"Connect"** → **"Start Web Terminal"**
3. You'll see a terminal window

### Step 4: Download the Code

In the terminal, run these commands **one by one**:

```bash
cd /workspace
```

```bash
git clone https://github.com/igabhix001/stable-diffusion-webui.git
```


```bash
cd stable-diffusion-webui
```

### Step 5: Confirm Python Version (IMPORTANT)

 This project is **tested with Python 3.10.6** (Python 3.10.x usually works, but avoid 3.11/3.12).

 Run:

```bash
python3.10 --version
```

 You must see **Python 3.10.x**.

 Recommended (tested): **Python 3.10.6**.

 If `python` is not 3.10.x, use `python3.10` in the commands below (or install Python 3.10 in your Runpod template).

 If `python3.10` is missing, install it (Ubuntu/Debian images):

 ```bash
 apt-get update
 apt-get install -y python3.10 python3.10-venv python3.10-dev
 ```

 After installing, confirm again:

 ```bash
 python3.10 --version
 ```

### Step 6: Download Required Models

Run these commands to download the AI models:

```bash
cd models/Stable-diffusion
```

```bash
wget "https://civitai.com/api/download/models/198530" -O juggernautXL_v6.safetensors
```

```bash
cd ..
```

```bash
mkdir -p layer_model
```

```bash
wget "https://huggingface.co/lllyasviel/LayerDiffuse_Diffusers/resolve/main/ld_diffusers_sdxl_attn.safetensors" \
  -O layer_model/layer_xl_transparent_attn.safetensors
```

```bash
wget "https://huggingface.co/lllyasviel/LayerDiffuse_Diffusers/resolve/main/ld_diffusers_sdxl_vae_transparent_decoder.safetensors" \
  -O layer_model/vae_transparent_decoder.safetensors
```

```bash
wget "https://huggingface.co/lllyasviel/LayerDiffuse_Diffusers/resolve/main/ld_diffusers_sdxl_vae_transparent_encoder.safetensors" \
  -O layer_model/vae_transparent_encoder.safetensors
```

```bash
cd ../..
```

### Step 7: Create Virtual Environment (Python 3.10.x)

```bash
python3.10 -m venv venv
```

```bash
source venv/bin/activate
```

```bash
python -m pip install --upgrade pip
```

#### Check GPU + Driver (recommended)

Run:

```bash
nvidia-smi
```

If `nvidia-smi` works, the GPU driver is available.

### Step 8: Start the API Server (API ONLY, no WebUI)

```bash
python launch.py --nowebui --api --listen --port 7861
```


First run can take **5-15 minutes** because it downloads and installs dependencies.

#### Verify CUDA + PyTorch

In another terminal (after the server starts or after install), run:

```bash
python -c "import torch; print('torch:', torch.__version__); print('cuda build:', torch.version.cuda); print('cuda available:', torch.cuda.is_available()); print('gpu:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A')"
```

> **Important:** Use `--nowebui` to run API-only mode (no web interface)

Wait until you see:
```
Application startup complete.
Uvicorn running on http://0.0.0.0:7861
```

### Step 9: Expose the Port

1. In Runpod dashboard, go to your pod
2. Click **"Connect"** 
3. Under **"TCP Port Mapping"**, add:
   - **Internal Port:** 7861
   - **External Port:** (leave blank, it will auto-assign)
4. Click **"Set Port"**
5. Copy the **External URL** (something like `https://abc123-7861.proxy.runpod.net`)

---

## If Torch/CUDA Installation Fails (Rare)

If you see an error like **"Your device does not support the current version of Torch/CUDA"**:

1. Stop the server
2. Try installing the **CUDA 11.8 (cu118)** wheels instead:

```bash
export TORCH_INDEX_URL="https://download.pytorch.org/whl/cu118"
python launch.py --reinstall-torch --nowebui --api --listen --port 7861
```

---

## Testing the API

### Test 1: Check if API is Running

In a new terminal tab (or your local computer), run:

```bash
curl https://YOUR_RUNPOD_URL/docs
```

You should see HTML content (the API documentation page).

### Test 2: Generate Your First Image

```bash
curl -X POST "https://YOUR_RUNPOD_URL/alpha/v1/txt2img" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "a red apple on white background, high quality"}'
```

**Expected Response:**
```json
{
  "url": "https://YOUR_RUNPOD_URL/alpha/v1/file/alpha_1234567890_abc123.png",
  "filename": "alpha_1234567890_abc123.png",
  "info": "..."
}
```

### Test 3: View the Generated Image

Copy the `url` from the response and open it in your browser. You should see a PNG image of a red apple with transparent background.

---

## API Usage

### Basic Request

```bash
curl -X POST "https://YOUR_RUNPOD_URL/alpha/v1/txt2img" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "YOUR_TEXT_HERE"}'
```

### Advanced Request

```bash
curl -X POST "https://YOUR_RUNPOD_URL/alpha/v1/txt2img" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a beautiful cat sitting on a chair, high quality",
    "negative_prompt": "blurry, low quality, ugly",
    "seed": 42
  }'
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `prompt` | Yes | - | What you want to generate |
| `negative_prompt` | No | "bad, ugly" | What to avoid |
| `seed` | No | 12345 | Number for consistent results |

---

## Important Settings

The API uses these fixed settings for best quality:

- **Image Size:** 1024x1024 pixels
- **Steps:** 20 (generation quality)
- **Sampler:** DPM++ 2M SDE Karras
- **CFG Scale:** 5
- **Format:** PNG with transparency

You cannot change these settings through the API - they're optimized for best results.

---

## Troubleshooting

### Problem: "CUDA out of memory"
**Solution:** Your GPU doesn't have enough memory. Use RTX 4090 (24GB) or RTX 3090 (24GB).

### Problem: "Model not found"
**Solution:** Make sure you downloaded the model file to `models/Stable-diffusion/`

### Problem: "Connection refused"
**Solution:** 
1. Make sure you used `--listen` flag when starting
2. Check that port 7861 is exposed in Runpod dashboard

### Problem: "Extension not working"
**Solution:** The LayerDiffuse extension is already included in your GitHub repo.

### Problem: API returns error 500
**Solution:** Check the terminal where you started the server for error messages.

---

## Support

If you encounter issues:
1. Check the terminal output for error messages
2. Verify all models are downloaded correctly
3. Ensure you're using a compatible GPU (12GB+ VRAM)
4. Make sure all commands were run in the correct order

---

*This guide is designed for non-technical users. Follow each step exactly as written.*
