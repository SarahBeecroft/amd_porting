FROM quay.io/pawsey/rocm-mpich-base:rocm6.3.3-mpich3.4.3-ubuntu24.04

# ROCm environment
ENV ROCM_RELEASE 6.3.3
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

# Configure pip to allow system-wide packages (appropriate for containers)
#RUN pip config set global.break-system-packages true

# Install pytorch 2.7    
RUN pip config set global.break-system-packages true && \
    pip install --no-cache-dir \
    torch==2.7.1 \
    torchvision==0.22.1 \
    torchaudio==2.7.1 \
    --index-url https://download.pytorch.org/whl/rocm6.3 

# Clone boltz release v.2.0.3
WORKDIR /opt
RUN git clone -b v2.0.3 https://github.com/jwohlwend/boltz.git
WORKDIR /opt/boltz

# Custom pyproject.toml
COPY pyproject.toml .
RUN apt remove -y python3-yaml python3-numpy
# Install boltz
RUN	pip install . --no-cache-dir
# Install these dependencies without allowing them to install non-rocm triton/torch etc
RUN pip install "wandb==0.18.7" "trifast==0.1.11" --no-deps --no-cache-dir

# Install additional dependencies
RUN pip install --no-cache-dir \
    platformdirs==4.3.8 \
    setproctitle==1.3.6 \
    sentry-sdk>=2.0.0 \
    psutil>=5.0.0 \
    docker-pycreds>=0.4.0 \
    "protobuf!=4.21.0,!=5.28.0,<6,>=3.19.0" \
    setuptools>=75.6.0 \
    "gitpython!=3.1.29,>=1.0.0" \
    jaxtyping
    
# Multiple labels in one instruction (preferred)
LABEL Boltz_version="v2.0.3" \
      Python_version="3.12" \
      maintainer="Pawsey Supercomputing Research Centre"
