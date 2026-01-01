# Test script for Alpha API with all generator presets
# Run this in a separate PowerShell terminal while the API is running

$apiUrl = "http://127.0.0.1:7861/alpha/v1/txt2img"
$outputDir = "E:\Imago-Gen\stable-diffusion-webui-forge\test_outputs"

# Create output directory
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "=== Testing Alpha API Generator Presets ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: General preset (default Juggernaut XL, no LoRA)
Write-Host "Test 1: General preset (realistic, no LoRA)" -ForegroundColor Yellow
$body1 = @{
    prompt = "a red apple on a wooden table, photorealistic"
    negative_prompt = "bad quality, blurry, distorted"
    generator_type = "general"
    seed = 12345
    steps = 20
} | ConvertTo-Json

try {
    $response1 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body1 -ContentType "application/json"
    if ($response1.url) {
        # Extract base64 from data URL and save
        $base64 = $response1.url -replace "^data:image/png;base64,", ""
        $bytes = [Convert]::FromBase64String($base64)
        [IO.File]::WriteAllBytes("$outputDir\test1_general.png", $bytes)
        Write-Host "✓ Saved: test1_general.png" -ForegroundColor Green
        Write-Host "  Filename: $($response1.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Aesthetic preset (Juggernaut XL with aesthetic prompt prefix)
Write-Host "Test 2: Aesthetic preset (high quality prompt enhancement)" -ForegroundColor Yellow
$body2 = @{
    prompt = "cinematic sunset over mountains, vibrant colors"
    negative_prompt = "bad quality, blurry"
    generator_type = "aesthetic"
    seed = 12345
    steps = 20
    cfg_scale = 5.0
} | ConvertTo-Json

try {
    $response2 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body2 -ContentType "application/json"
    if ($response2.url) {
        $base64 = $response2.url -replace "^data:image/png;base64,", ""
        $bytes = [Convert]::FromBase64String($base64)
        [IO.File]::WriteAllBytes("$outputDir\test2_aesthetic.png", $bytes)
        Write-Host "✓ Saved: test2_aesthetic.png" -ForegroundColor Green
        Write-Host "  Filename: $($response2.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Logo preset (Juggernaut XL + geometric-logo LoRA)
Write-Host "Test 3: Logo preset (geometric-logo LoRA)" -ForegroundColor Yellow
$body3 = @{
    prompt = "minimalist fox logo, orange and white, simple"
    negative_prompt = "complex, detailed, photorealistic, 3d"
    generator_type = "logo"
    seed = 12345
    steps = 20
    cfg_scale = 5.0
} | ConvertTo-Json

try {
    $response3 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body3 -ContentType "application/json"
    if ($response3.url) {
        $base64 = $response3.url -replace "^data:image/png;base64,", ""
        $bytes = [Convert]::FromBase64String($base64)
        [IO.File]::WriteAllBytes("$outputDir\test3_logo.png", $bytes)
        Write-Host "✓ Saved: test3_logo.png" -ForegroundColor Green
        Write-Host "  Filename: $($response3.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: 3D Icon preset (Juggernaut XL + 3d-icon-lora LoRA)
Write-Host "Test 4: 3D Icon preset (3d-icon-lora LoRA)" -ForegroundColor Yellow
$body4 = @{
    prompt = "shopping cart icon, glossy, colorful"
    negative_prompt = "flat, 2d, simple, minimal"
    generator_type = "icon_3d"
    seed = 12345
    steps = 20
    cfg_scale = 5.0
} | ConvertTo-Json

try {
    $response4 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body4 -ContentType "application/json"
    if ($response4.url) {
        $base64 = $response4.url -replace "^data:image/png;base64,", ""
        $bytes = [Convert]::FromBase64String($base64)
        [IO.File]::WriteAllBytes("$outputDir\test4_icon3d.png", $bytes)
        Write-Host "✓ Saved: test4_icon3d.png" -ForegroundColor Green
        Write-Host "  Filename: $($response4.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: Custom explicit LoRA override
Write-Host "Test 5: Custom LoRA override (explicit geometric-logo with weight 0.9)" -ForegroundColor Yellow
$body5 = @{
    prompt = "geometric wolf logo, blue and silver"
    negative_prompt = "photorealistic, detailed fur, 3d"
    checkpoint = "juggernautXL_version6Rundiffusion.safetensors"
    loras = @(
        @{
            name = "geometric-logo"
            weight = 0.9
        }
    )
    seed = 12349
    steps = 20
    cfg_scale = 5.0
    sampler_name = "DPM++ 2M SDE"
} | ConvertTo-Json -Depth 3

try {
    $response5 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body5 -ContentType "application/json"
    if ($response5.url) {
        $base64 = $response5.url -replace "^data:image/png;base64,", ""
        $bytes = [Convert]::FromBase64String($base64)
        [IO.File]::WriteAllBytes("$outputDir\test5_custom_lora.png", $bytes)
        Write-Host "✓ Saved: test5_custom_lora.png" -ForegroundColor Green
        Write-Host "  Filename: $($response5.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Full manual parameter override
Write-Host "Test 6: Full manual parameters (all options)" -ForegroundColor Yellow
$body6 = @{
    prompt = "majestic dragon flying over castle, epic fantasy"
    negative_prompt = "bad quality, blurry, low resolution, deformed"
    generator_type = "aesthetic"
    seed = 99999
    steps = 35
    sampler_name = "DPM++ 2M Karras"
    scheduler = "Karras"
    cfg_scale = 8.0
    width = 1024
    height = 768
    batch_size = 1
    restore_faces = $false
    tiling = $false
} | ConvertTo-Json

try {
    $response6 = Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body6 -ContentType "application/json"
    if ($response6.url) {
        $base64 = $response6.url -replace "^data:image/png;base64,", ""
        $bytes = [Convert]::FromBase64String($base64)
        [IO.File]::WriteAllBytes("$outputDir\test6_full_params.png", $bytes)
        Write-Host "✓ Saved: test6_full_params.png" -ForegroundColor Green
        Write-Host "  Filename: $($response6.filename)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== Testing Complete ===" -ForegroundColor Cyan
Write-Host "Check output directory: $outputDir" -ForegroundColor Gray
Write-Host ""
Write-Host "Verify transparent PNG:" -ForegroundColor Yellow
Write-Host "  - Open images in image viewer that supports transparency" -ForegroundColor Gray
Write-Host "  - Check if background is transparent (not white/black)" -ForegroundColor Gray
Write-Host "  - Logo/Icon presets should show LoRA style effects" -ForegroundColor Gray
