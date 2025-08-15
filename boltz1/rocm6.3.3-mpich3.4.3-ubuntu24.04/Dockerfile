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

# Clone boltz release v1.0.0
WORKDIR /opt
RUN git clone -b v1.0.0 https://github.com/jwohlwend/boltz.git
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
    "gitpython!=3.1.29,>=1.0.0"
    
# Multiple labels in one instruction (preferred)
LABEL Boltz_version="v1.0.0" \
      Python_version="3.12" \
      maintainer="Pawsey Supercomputing Research Centre"

# Full pip freeze output for reference
# aiohappyeyeballs==2.6.1
# aiohttp==3.12.15
# aiosignal==1.4.0
# amdsmi @ file:///opt/rocm-6.3.3/share/amd_smi
# antlr4-python3-runtime==4.9.3
# argcomplete==3.1.4
# asttokens==3.0.0
# attrs==25.3.0
# biopython==1.84
# blinker==1.7.0
# boltz @ file:///opt/boltz
# certifi==2025.8.3
# charset-normalizer==3.4.3
# click==8.1.7
# cryptography==41.0.7
# dbus-python==1.3.2
# decorator==5.1.1
# devscripts==2.23.7
# distro==1.9.0
# dm-tree==0.1.8
# docker-pycreds==0.4.0
# e3nn==0.5.6
# einops==0.8.0
# einx==0.3.0
# executing==2.2.0
# fairscale==0.4.13
# filelock==3.13.1
# frozendict==2.4.6
# frozenlist==1.7.0
# fsspec==2024.6.1
# gcovr==7.0
# gitdb==4.0.12
# GitPython==3.1.45
# httplib2==0.20.4
# hydra-core==1.3.2
# icecream==2.1.5
# idna==3.10
# ihm==2.7
# jaxtyping==0.3.2
# Jinja2==3.1.2
# launchpadlib==1.11.0
# lazr.restfulclient==0.14.6
# lazr.uri==1.0.6
# lightning-utilities==0.15.2
# llvmlite==0.44.0
# lxml==5.2.1
# MarkupSafe==2.1.5
# mashumaro==3.14
# modelcif==1.2
# mpi4py==3.1.5
# mpmath==1.3.0
# msgpack==1.1.1
# multidict==6.6.3
# networkx==3.3
# numba==0.61.0
# numpy==1.26.3
# oauthlib==3.2.2
# omegaconf==2.3.0
# packaging==25.0
# pandas==2.3.1
# pillow==11.0.0
# platformdirs==4.3.8
# propcache==0.3.2
# protobuf==5.29.5
# psutil==7.0.0
# Pygments==2.17.2
# PyGObject==3.48.2
# PyJWT==2.7.0
# pyparsing==3.1.1
# pyro-api==0.1.2
# python-apt==2.7.7+ubuntu4
# python-dateutil==2.9.0.post0
# pytorch-lightning==2.4.0
# pytorch-triton-rocm==3.3.1
# pytz==2025.2
# PyYAML==6.0.2
# rdkit==2025.3.5
# requests==2.32.3
# scipy==1.13.1
# sentry-sdk==2.34.1
# setproctitle==1.3.6
# setuptools==68.1.2
# six==1.16.0
# smmap==5.0.2
# sympy==1.13.3
# torch==2.7.1+rocm6.3
# torchaudio==2.7.1+rocm6.3
# torchmetrics==1.8.1
# torchvision==0.22.1+rocm6.3
# tqdm==4.67.1
# trifast==0.1.11
# types-requests==2.32.4.20250809
# typing_extensions==4.12.2
# tzdata==2025.2
# urllib3==2.5.0
# wadler_lindig==0.1.7
# wadllib==1.3.6
# wandb==0.18.7
# wheel==0.42.0
