#!/bin/bash
# Test script for Alpha API using curl
# Run this in Git Bash or WSL while the API is running

API_URL="http://127.0.0.1:7861/alpha/v1/txt2img"
OUTPUT_DIR="test_outputs"

mkdir -p "$OUTPUT_DIR"

echo "=== Testing Alpha API Generator Presets ==="
echo ""

# Test 1: General preset
echo "Test 1: General preset (realistic, no LoRA)"
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a red apple on a wooden table, photorealistic",
    "negative_prompt": "bad quality, blurry",
    "generator_type": "general",
    "seed": 12345,
    "steps": 20
  }' \
  -o "$OUTPUT_DIR/test1_general_response.json"
echo ""

# Test 2: Aesthetic preset
echo "Test 2: Aesthetic preset"
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "cinematic sunset over mountains",
    "generator_type": "aesthetic",
    "seed": 12346,
    "steps": 25
  }' \
  -o "$OUTPUT_DIR/test2_aesthetic_response.json"
echo ""

# Test 3: Logo preset (with LoRA)
echo "Test 3: Logo preset (geometric-logo LoRA)"
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "minimalist fox logo, orange and white",
    "negative_prompt": "complex, detailed, photorealistic",
    "generator_type": "logo",
    "seed": 12347,
    "steps": 25
  }' \
  -o "$OUTPUT_DIR/test3_logo_response.json"
echo ""

# Test 4: 3D Icon preset (with LoRA)
echo "Test 4: 3D Icon preset (3d-icon-lora LoRA)"
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "shopping cart icon, glossy",
    "generator_type": "icon_3d",
    "seed": 12348,
    "steps": 25
  }' \
  -o "$OUTPUT_DIR/test4_icon3d_response.json"
echo ""

# Test 5: Custom LoRA override
echo "Test 5: Custom LoRA with explicit weight"
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "geometric wolf logo, blue and silver",
    "checkpoint": "juggernautXL_version6Rundiffusion.safetensors",
    "loras": [{"name": "geometric-logo", "weight": 0.9}],
    "seed": 12349,
    "steps": 30
  }' \
  -o "$OUTPUT_DIR/test5_custom_response.json"
echo ""

echo "=== Tests Complete ==="
echo "Check $OUTPUT_DIR for JSON responses"
echo "Extract base64 from 'url' or 'image_base64' fields to save images"
