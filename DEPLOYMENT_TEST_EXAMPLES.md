# Complete API Test Examples

## Test 1: Fox Cartoon 

### Full Payload
```json
{
  "input": {
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
  }
}
```

### PowerShell Command
```powershell
$body = @{
    input = @{
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
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://127.0.0.1:7860/alpha/v1/txt2img" -Method POST -Body $body -ContentType "application/json"
```

### Curl Command
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

---

## Test 2: Coffee Mug 

### Full Payload
```json
{
  "input": {
    "prompt": "high quality studio photo of a white ceramic coffee mug with a small blue logo, centered on a pure white background, soft shadows, 3 point lighting, 8k, ultra detailed, clean, minimal, product photography",
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
  }
}
```

### PowerShell Command
```powershell
$body = @{
    input = @{
        prompt = "high quality studio photo of a white ceramic coffee mug with a small blue logo, centered on a pure white background, soft shadows, 3 point lighting, 8k, ultra detailed, clean, minimal, product photography"
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
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://127.0.0.1:7860/alpha/v1/txt2img" -Method POST -Body $body -ContentType "application/json"
```

---

## Test 3: Logo Preset with LoRA

### Full Payload
```json
{
  "input": {
    "prompt": "minimalist wolf logo, blue and white, simple",
    "negative_prompt": "complex, detailed, photorealistic, 3d",
    "generator_type": "logo",
    "seed": 12345,
    "steps": 20,
    "cfg_scale": 5.0
  }
}
```

**Note:** The `logo` preset automatically:
- Uses JuggernautXL v9 checkpoint
- Adds `geometric-logo` LoRA (weight 0.85)
- Adds trigger words: "flat-line-logo, geometric"
- Enables LayerDiffuse for transparent background

---

## Test 4: 3D Icon Preset

### Full Payload
```json
{
  "input": {
    "prompt": "shopping cart icon, glossy, colorful",
    "negative_prompt": "flat, 2d, simple, minimal",
    "generator_type": "icon_3d",
    "seed": 12345,
    "steps": 20,
    "cfg_scale": 5.0
  }
}
```

**Note:** The `icon_3d` preset automatically:
- Uses JuggernautXL v9 checkpoint
- Adds `3d-icon-lora` LoRA (weight 0.85)
- Adds trigger words: "<s0><s1>"
- Enables LayerDiffuse for transparent background

---

## Test 5: JuggernautXL v6 (Legacy)

### Full Payload
```json
{
  "input": {
    "prompt": "a red apple on wooden table, photorealistic",
    "negative_prompt": "bad quality, blurry",
    "generator_type": "general_v6",
    "seed": 12345,
    "steps": 20
  }
}
```

---

## Test 6: Disable LayerDiffuse (Solid Background)

### Full Payload
```json
{
  "input": {
    "prompt": "beautiful sunset over mountains",
    "negative_prompt": "bad quality, blurry",
    "seed": 12345,
    "steps": 20,
    "layerdiffuse_enabled": false
  }
}
```

**Note:** Setting `layerdiffuse_enabled: false` disables transparent background generation.

---

## Test 7: Custom LoRA with Manual Parameters

### Full Payload
```json
{
  "input": {
    "prompt": "geometric wolf logo, blue and silver",
    "negative_prompt": "photorealistic, detailed fur, 3d",
    "checkpoint": "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors",
    "loras": [
      {
        "name": "geometric-logo",
        "weight": 0.95
      }
    ],
    "seed": 12345,
    "steps": 30,
    "cfg_scale": 5.0,
    "sampler_name": "DPM++ 2M SDE"
  }
}
```

**Note:** When using explicit `checkpoint` and `loras`, trigger words are NOT auto-added. You must include them in your prompt.

---

## All Available Parameters

### Complete Parameter List
```json
{
  "input": {
    // REQUIRED
    "prompt": "your prompt here",
    
    // BASIC PARAMETERS
    "negative_prompt": "bad, ugly",
    "seed": 12345,
    "steps": 20,
    "sampler_name": "DPM++ 2M SDE",
    "scheduler": "Karras",
    "cfg_scale": 5.0,
    "width": 1024,
    "height": 1024,
    "batch_size": 1,
    "n_iter": 1,
    
    // ADVANCED PARAMETERS
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
    
    // MODEL SELECTION
    "generator_type": "general",
    "checkpoint": "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors",
    "loras": [
      {"name": "lora-name", "weight": 0.85}
    ],
    
    // LAYERDIFFUSE EXTENSION
    "layerdiffuse_enabled": true,
    "layerdiffuse_method": "(SDXL) Only Generate Transparent Image (Attention Injection)",
    "layerdiffuse_weight": 1.0,
    "layerdiffuse_stop_at": 1.0,
    "layerdiffuse_resize_mode": "Crop and Resize",
    "layerdiffuse_output_origin": false,
    
    // REFINER
    "refiner_checkpoint": null,
    "refiner_switch_at": null,
    
    // OVERRIDE SETTINGS
    "override_settings": {}
  }
}
```

---

## Generator Presets

| Preset | Checkpoint | LoRAs | Trigger Words | Use Case |
|--------|------------|-------|---------------|----------|
| `general` | JuggernautXL v9 | None | - | Realistic images, general purpose |
| `general_v6` | JuggernautXL v6 | None | - | Legacy v6 checkpoint |
| `aesthetic` | JuggernautXL v9 | None | - | High quality (adds quality keywords) |
| `logo` | JuggernautXL v9 | geometric-logo (0.85) | `flat-line-logo, geometric` | Geometric/minimal logos |
| `icon_3d` | JuggernautXL v9 | 3d-icon-lora (0.85) | `<s0><s1>` | 3D glossy icons |

---

## LayerDiffuse Methods

Available methods for `layerdiffuse_method`:
- `(SDXL) Only Generate Transparent Image (Attention Injection)` (default)
- Other SDXL LayerDiffuse methods supported by the extension

---

## Response Format

```json
{
  "url": "http://127.0.0.1:7860/alpha/v1/file/alpha_1234567890_token.png",
  "filename": "alpha_1234567890_token.png",
  "image_base64": "iVBORw0KGgoAAAANSUhEUgAA...",
  "info": "generation metadata and parameters"
}
```

- `url`: Direct URL to download the PNG file
- `filename`: Filename of the generated image
- `image_base64`: Base64 encoded PNG data (can be decoded and saved directly)
- `info`: JSON string with generation parameters and metadata
