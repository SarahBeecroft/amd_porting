FROM quay.io/sarahbeecroft9/openfold:v1.0.1

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install ESMFold dependencies
RUN	pip install --no-cache-dir git+https://github.com/facebookresearch/esm.git
RUN	pip install --no-cache-dir \
    PyYAML==5.4.1 \
    requests==2.26.0 \
    tqdm==4.62.2 \
    typing-extensions \
    matplotlib \ 
    einops \
    omegaconf \
    wandb==0.12.21 \
    biotite \
    "pydantic<2.0"

RUN	pip install --no-cache-dir deepspeed==0.9.2
COPY primitives.py /opt/openfold/openfold/model/primitives.py
