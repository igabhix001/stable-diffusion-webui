# PowerShell script to test LayerDiffuse Alpha API locally
# Based on UI configuration from screenshots

$apiUrl = "http://127.0.0.1:7860/alpha/v1/txt2img"
$outputDir = "E:\Imago-Gen\stable-diffusion-webui-forge\test_outputs"

# Create output directory
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "=== Testing LayerDiffuse Alpha API Locally ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Fox cartoon with all UI parameters from screenshot 1
Write-Host "Test 1: Fox cartoon (matching UI config from screenshot)" -ForegroundColor Yellow
$body1 = @{
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
    # LayerDiffuse parameters from UI
    layerdiffuse_enabled = $true
    layerdiffuse_method = "(SDXL) Only Generate Transparent Image (Attention Injection)"
    layerdiffuse_weight = 1.0
    layerdiffuse_stop_at = 1.0
    layerdiffuse_resize_mode = "Crop and Resize"
    layerdiffuse_output_origin = $false
} | ConvertTo-Json -Depth 3

try {
    Write-Host "Sending request..." -ForegroundColor Gray
    $response1 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body1 -ContentType "application/json" -TimeoutSec 300
    
    if ($response1.image_base64) {
        $bytes = [Convert]::FromBase64String($response1.image_base64)
        [IO.File]::WriteAllBytes("$outputDir\test1_fox_cartoon.png", $bytes)
        Write-Host "Success - Saved: test1_fox_cartoon.png" -ForegroundColor Green
        Write-Host "  Filename: $($response1.filename)" -ForegroundColor Gray
        Write-Host "  URL: $($response1.url)" -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Coffee mug with all UI parameters from screenshot 2
Write-Host "Test 2: Coffee mug " -ForegroundColor Yellow
$body2 = @{
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
    # LayerDiffuse parameters from UI
    layerdiffuse_enabled = $false
    layerdiffuse_method = "(SDXL) Only Generate Transparent Image (Attention Injection)"
    layerdiffuse_weight = 1.0
    layerdiffuse_stop_at = 1.0
    layerdiffuse_resize_mode = "Crop and Resize"
    layerdiffuse_output_origin = $false
} | ConvertTo-Json -Depth 3

try {
    Write-Host "Sending request..." -ForegroundColor Gray
    $response2 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body2 -ContentType "application/json" -TimeoutSec 300
    
    if ($response2.image_base64) {
        $bytes = [Convert]::FromBase64String($response2.image_base64)
        [IO.File]::WriteAllBytes("$outputDir\test2_coffee_mug.png", $bytes)
        Write-Host "Success - Saved: test2_coffee_mug.png" -ForegroundColor Green
        Write-Host "  Filename: $($response2.filename)" -ForegroundColor Gray
        Write-Host "  URL: $($response2.url)" -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Logo preset with geometric LoRA
Write-Host "Test 3: Logo preset (geometric-logo LoRA)" -ForegroundColor Yellow
$body3 = @{
    prompt = "minimalist wolf logo, blue and white, simple"
    negative_prompt = "complex, detailed, photorealistic, 3d"
    generator_type = "logo"
    seed = 12345
    steps = 20
    cfg_scale = 5.0
} | ConvertTo-Json -Depth 3

try {
    Write-Host "Sending request..." -ForegroundColor Gray
    $response3 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body3 -ContentType "application/json" -TimeoutSec 300
    
    if ($response3.image_base64) {
        $bytes = [Convert]::FromBase64String($response3.image_base64)
        [IO.File]::WriteAllBytes("$outputDir\test3_logo_preset.png", $bytes)
        Write-Host "Success - Saved: test3_logo_preset.png" -ForegroundColor Green
        Write-Host "  Filename: $($response3.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: 3D Icon preset
Write-Host "Test 4: 3D Icon preset (3d-icon-lora LoRA)" -ForegroundColor Yellow
$body4 = @{
    prompt = "shopping cart icon, glossy, colorful"
    negative_prompt = "flat, 2d, simple, minimal"
    generator_type = "icon_3d"
    seed = 12345
    steps = 20
    cfg_scale = 5.0
} | ConvertTo-Json -Depth 3

try {
    Write-Host "Sending request..." -ForegroundColor Gray
    $response4 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body4 -ContentType "application/json" -TimeoutSec 300
    
    if ($response4.image_base64) {
        $bytes = [Convert]::FromBase64String($response4.image_base64)
        [IO.File]::WriteAllBytes("$outputDir\test4_icon3d_preset.png", $bytes)
        Write-Host "Success - Saved: test4_icon3d_preset.png" -ForegroundColor Green
        Write-Host "  Filename: $($response4.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: JuggernautXL v6 (general_v6 preset)
Write-Host "Test 5: JuggernautXL v6 preset" -ForegroundColor Yellow
$body5 = @{
    prompt = "a red apple on wooden table, photorealistic"
    negative_prompt = "bad quality, blurry"
    generator_type = "general_v6"
    seed = 12345
    steps = 20
} | ConvertTo-Json -Depth 3

try {
    Write-Host "Sending request..." -ForegroundColor Gray
    $response5 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body5 -ContentType "application/json" -TimeoutSec 300
    
    if ($response5.image_base64) {
        $bytes = [Convert]::FromBase64String($response5.image_base64)
        [IO.File]::WriteAllBytes("$outputDir\test5_v6_preset.png", $bytes)
        Write-Host "Success - Saved: test5_v6_preset.png" -ForegroundColor Green
        Write-Host "  Filename: $($response5.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Disable LayerDiffuse (solid background)
Write-Host "Test 6: LayerDiffuse disabled (solid background)" -ForegroundColor Yellow
$body6 = @{
    prompt = "beautiful sunset over mountains"
    negative_prompt = "bad quality, blurry"
    seed = 12345
    steps = 20
    layerdiffuse_enabled = $false
} | ConvertTo-Json -Depth 3

try {
    Write-Host "Sending request..." -ForegroundColor Gray
    $response6 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body6 -ContentType "application/json" -TimeoutSec 300
    
    if ($response6.image_base64) {
        $bytes = [Convert]::FromBase64String($response6.image_base64)
        [IO.File]::WriteAllBytes("$outputDir\test6_no_transparency.png", $bytes)
        Write-Host "Success - Saved: test6_no_transparency.png" -ForegroundColor Green
        Write-Host "  Filename: $($response6.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== Testing Complete ===" -ForegroundColor Cyan
Write-Host "Output directory: $outputDir" -ForegroundColor Gray
Write-Host ""
Write-Host "Verification:" -ForegroundColor Yellow
Write-Host "  - Open PNG files in image viewer that supports transparency" -ForegroundColor Gray
Write-Host "  - Tests 1-5 should have transparent backgrounds" -ForegroundColor Gray
Write-Host "  - Test 6 should have solid background (LayerDiffuse disabled)" -ForegroundColor Gray
Write-Host "  - Tests 3-4 should show LoRA style effects" -ForegroundColor Gray
