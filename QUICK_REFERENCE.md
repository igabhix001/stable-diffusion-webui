# LayerDiffuse Alpha API - Quick Reference Card

## Minimal Request (Just Prompt)
```json
{"input": {"prompt": "your text here"}}
```

## Generator Presets
- `"generator_type": "general"` - Realistic images
- `"generator_type": "aesthetic"` - High quality (auto-enhances prompt)
- `"generator_type": "logo"` - Geometric logos (auto-adds trigger words + LoRA)
- `"generator_type": "icon_3d"` - 3D icons (auto-adds trigger words + LoRA)

## Most Common Overrides
```json
{
  "seed": -1,                    // Random seed
  "steps": 30,                   // Higher quality
  "cfg_scale": 7.5,              // Follow prompt more strictly
  "sampler_name": "Euler a",     // Fast sampler
  "width": 1280, "height": 768   // Landscape
}
```

## Custom LoRA
```json
{
  "loras": [{"name": "geometric-logo", "weight": 0.9}]
}
```

## Key Facts
- ✅ **Only `prompt` is required** - all else is optional
- ✅ **Transparent PNG always** - LayerDiffuse cannot be disabled
- ✅ **JuggernautXL v9** - single checkpoint for all presets
- ✅ **Any SDXL LoRA works** - just add to `models/Lora/` folder
- ✅ **All parameters can be overridden** - no restrictions

## Exact Model Names (Case-Sensitive)
**Checkpoint:**
- `Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors`

**LoRAs:**
- `geometric-logo` (NOT geometric_logo)
- `3d-icon-lora` (NOT 3d_icon_lora)

## Trigger Words (Required for Custom LoRA Usage)
- **geometric-logo:** `flat-line-logo, geometric`
- **3d-icon-lora:** `<s0><s1>`

**Note:** Presets auto-add trigger words. Only needed when using `loras` parameter directly.

## Common Mistakes
❌ Wrong: `"checkpoint": "juggernautXL_v6.safetensors"`  
✅ Correct: `"checkpoint": "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"`

❌ Wrong: `"loras": [{"name": "geometric_logo"}]`  
✅ Correct: `"loras": [{"name": "geometric-logo"}]`

❌ Wrong: Using SD1.5 or Flux LoRAs  
✅ Correct: Only SDXL-compatible LoRAs

## API Endpoint
```
POST https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync
Headers:
  Authorization: Bearer YOUR_API_KEY
  Content-Type: application/json
```

## Full Documentation
See `DEPLOYMENT.md` for complete parameter reference, examples, and troubleshooting.
