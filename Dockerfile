# Dockerfile for RunPod Serverless - LayerDiffuse Alpha API
# This builds a complete image with Forge, models, and serverless handler

FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    git \
    wget \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Create workspace directory
WORKDIR /workspace

# Clone the repository (your customized Forge with alpha API)
# Replace with your actual GitHub repo URL
RUN git clone https://github.com/igabhix001/stable-diffusion-webui.git

WORKDIR /workspace/stable-diffusion-webui

# Create virtual environment and install base dependencies
RUN python -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install runpod requests

# Download models during build (baked into image)
# ============================================
# BASE CHECKPOINTS (SDXL-based for LayerDiffuse compatibility)
# ============================================
RUN mkdir -p models/Stable-diffusion && \
    # JuggernautXL v6 - General purpose, realistic
    wget -q "https://civitai.com/api/download/models/198530" -O models/Stable-diffusion/juggernautXL_version6Rundiffusion.safetensors && \
    # JuggernautXL v9 - High quality, photorealistic, best prompt adherence
    wget -q "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
        -O models/Stable-diffusion/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors

# ============================================
# LORA MODELS (SDXL-compatible for style variations)
# ============================================
RUN mkdir -p models/Lora && \
    # 3D Icon LoRA - For 3D style icons
    wget -q "https://huggingface.co/Cicistawberry/3d-icon-lora/resolve/main/3d_icon_lora.safetensors" \
        -O models/Lora/3d-icon-lora.safetensors && \
    # Geometric Logo LoRA - For geometric/minimal logos
    wget -q "https://huggingface.co/Sologo-AI/Geometric-logo/resolve/main/Geometric-logo.safetensors" \
        -O models/Lora/geometric-logo.safetensors

# ============================================
# LAYERDIFFUSE MODELS (for transparent PNG output)
# ============================================
RUN mkdir -p models/layer_model && \
    wget -q "https://huggingface.co/LayerDiffusion/layerdiffusion-v1/resolve/main/layer_xl_transparent_attn.safetensors" \
        -O models/layer_model/layer_xl_transparent_attn.safetensors && \
    wget -q "https://huggingface.co/LayerDiffusion/layerdiffusion-v1/resolve/main/vae_transparent_decoder.safetensors" \
        -O models/layer_model/vae_transparent_decoder.safetensors && \
    wget -q "https://huggingface.co/LayerDiffusion/layerdiffusion-v1/resolve/main/vae_transparent_encoder.safetensors" \
        -O models/layer_model/vae_transparent_encoder.safetensors

# Install Forge dependencies (this will also install torch with CUDA)
# Run launch.py once to install all dependencies, then exit
RUN . venv/bin/activate && \
    python launch.py --skip-torch-cuda-test --exit

# Install runpod SDK
RUN . venv/bin/activate && pip install runpod

# Copy the serverless handler and start script
COPY rp_handler.py /workspace/stable-diffusion-webui/rp_handler.py
COPY start.sh /workspace/stable-diffusion-webui/start.sh
RUN chmod +x /workspace/stable-diffusion-webui/start.sh

# Set the entrypoint
CMD ["/workspace/stable-diffusion-webui/start.sh"]
