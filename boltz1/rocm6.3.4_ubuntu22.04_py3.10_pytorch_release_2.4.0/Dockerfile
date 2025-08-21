FROM rocm/pytorch:rocm6.3.4_ubuntu22.04_py3.10_pytorch_release_2.4.0

# ROCm environment
ENV ROCM_RELEASE 6.3.4
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE

# Update environment
RUN apt-get update && \
    apt install apt-transport-https -y && \
    apt-get install -y \
    build-essential \
    git \
    libxml2 \	
    gcc \
    g++ \
    doxygen \
    autoconf \
    rccl \
    && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

# Install pytorch 2.7    
RUN pip3 install --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.3

# Clone boltz release v1.0.0
WORKDIR /opt
RUN git clone -b v1.0.0 https://github.com/jwohlwend/boltz.git
WORKDIR /opt/boltz

# Custom pyproject.toml
COPY pyproject.toml .

# Install boltz
RUN	pip install . --no-cache-dir
# Install these dependencies without allowing them to install non-rocm triton/torch etc
RUN pip install "wandb==0.18.7" "trifast>=0.1.11" --no-deps --no-cache-dir
