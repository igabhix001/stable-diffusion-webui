"""
RunPod Serverless Handler for LayerDiffuse Alpha API
This handler wraps the Forge API to provide serverless txt2img with transparent backgrounds.

API behavior matches the original FastAPI endpoints:
- POST /alpha/v1/txt2img (prompt in → URL + image data out)
- The image is returned as a data URL that can be used directly
"""
import runpod
import requests
import time
import base64
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Forge API runs on localhost inside the container
FORGE_API_URL = "http://127.0.0.1:7861"
TIMEOUT = 300  # 5 minutes for image generation


def wait_for_forge_api(max_retries: int = 300, retry_interval: float = 1.0) -> bool:
    """
    Wait for Forge API to become available.
    """
    logger.info("Waiting for Forge API to start...")
    
    for attempt in range(max_retries):
        try:
            response = requests.get(f"{FORGE_API_URL}/sdapi/v1/sd-models", timeout=5)
            if response.status_code == 200:
                logger.info(f"Forge API is ready after {attempt + 1} attempts")
                return True
        except requests.exceptions.RequestException:
            pass
        
        if attempt % 30 == 0 and attempt > 0:
            logger.info(f"Still waiting for Forge API... ({attempt} seconds)")
        
        time.sleep(retry_interval)
    
    logger.error("Forge API failed to start within timeout")
    return False


def generate_image(prompt: str, negative_prompt: str = "bad, ugly", seed: int = None) -> dict:
    """
    Generate a transparent PNG image using the Forge Alpha API.
    
    Returns response matching the original /alpha/v1/txt2img format:
    - url: Data URL (data:image/png;base64,...) that works in browsers
    - filename: The generated filename
    - image_base64: Raw base64 for programmatic use
    """
    payload = {
        "prompt": prompt,
        "negative_prompt": negative_prompt,
    }
    
    if seed is not None:
        payload["seed"] = seed
    
    try:
        # Call the custom alpha endpoint that has LayerDiffuse baked in
        response = requests.post(
            f"{FORGE_API_URL}/alpha/v1/txt2img",
            json=payload,
            timeout=TIMEOUT
        )
        
        if response.status_code == 200:
            result = response.json()
            
            if "url" in result:
                # Fetch the image from the local URL
                image_url = result["url"]
                # Convert to local URL (replace external URL with localhost)
                local_url = image_url.replace(
                    image_url.split("/alpha/")[0],
                    FORGE_API_URL
                )
                
                img_response = requests.get(local_url, timeout=30)
                if img_response.status_code == 200:
                    image_bytes = img_response.content
                    filename = result.get("filename", "output.png")
                    
                    # Save the image to the outputs directory (same as original API)
                    # This allows the file to be served via the /alpha/v1/file/{filename} endpoint
                    # during the lifetime of this serverless request
                    import os
                    output_dir = "/workspace/stable-diffusion-webui/outputs/txt2img-images"
                    os.makedirs(output_dir, exist_ok=True)
                    output_path = os.path.join(output_dir, filename)
                    
                    with open(output_path, "wb") as f:
                        f.write(image_bytes)
                    
                    # For Runpod serverless, we need to return the image data
                    # Runpod will automatically upload it to their CDN and provide a URL
                    # The output format matches the original API
                    image_base64 = base64.b64encode(image_bytes).decode("utf-8")
                    
                    # Return in format matching original API
                    # Note: In serverless, the "url" will be a data URL since the container is ephemeral
                    # The client should use image_base64 to save the file or display it
                    return {
                        "status": "success",
                        "url": f"data:image/png;base64,{image_base64}",  # Data URL for immediate use
                        "filename": filename,
                        "image_base64": image_base64,  # Raw base64 for saving to file
                        "info": result.get("info", "")
                    }
                else:
                    return {
                        "status": "error",
                        "error": f"Failed to fetch generated image: {img_response.status_code}"
                    }
            else:
                return {
                    "status": "error",
                    "error": "No URL in response from Forge API"
                }
        else:
            return {
                "status": "error",
                "error": f"Forge API returned status {response.status_code}: {response.text}"
            }
            
    except requests.exceptions.Timeout:
        return {
            "status": "error",
            "error": "Image generation timed out"
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }


def handler(job: dict) -> dict:
    """
    RunPod Serverless handler function.
    
    Matches the original /alpha/v1/txt2img API behavior.
    
    Expected input:
    {
        "input": {
            "prompt": "a red apple, high quality",
            "negative_prompt": "bad, ugly",  // optional
            "seed": 12345  // optional
        }
    }
    
    Returns (matching original API format):
    {
        "status": "success",
        "url": "data:image/png;base64,...",  // Data URL, works in <img src="">
        "filename": "alpha_xxx.png",
        "image_base64": "...",  // Raw base64 for saving to file
        "info": "generation metadata"
    }
    """
    job_input = job.get("input", {})
    
    # Validate required input
    prompt = job_input.get("prompt")
    if not prompt:
        return {
            "status": "error",
            "error": "Missing required field: prompt"
        }
    
    # Optional parameters
    negative_prompt = job_input.get("negative_prompt", "bad, ugly")
    seed = job_input.get("seed")
    
    logger.info(f"Processing job: prompt='{prompt[:50]}...' seed={seed}")
    
    # Generate the image
    result = generate_image(prompt, negative_prompt, seed)
    
    if result["status"] == "success":
        logger.info(f"Successfully generated image: {result['filename']}")
    else:
        logger.error(f"Failed to generate image: {result.get('error')}")
    
    return result


# Entry point
if __name__ == "__main__":
    # Wait for Forge API to be ready before starting serverless handler
    if wait_for_forge_api():
        logger.info("Starting RunPod Serverless handler...")
        runpod.serverless.start({"handler": handler})
    else:
        logger.error("Failed to start: Forge API not available")
        exit(1)
