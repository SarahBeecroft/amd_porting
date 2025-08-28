FROM quay.io/pawsey/rocm-mpich-base:rocm6.2.4-mpich3.4.3-ubuntu24.04

# Use bash to support string substitution.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update --quiet \
    && apt-get install --no-install-recommends --yes --quiet \
        build-essential \
        cmake \
        git \
        tzdata \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove --yes \
    && apt-get clean

WORKDIR /opt

# ROCm environment
ENV ROCM_RELEASE 6.2.4
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE
ENV PATH $ROCM_PATH/bin:$ROCM_PATH/llvm/bin:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROCM_PATH/lib
ENV JAX_PLATFORMS="rocm"

# Install miniforge (mamba)
RUN set -eux ; \
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" ; \
    bash Miniforge3-$(uname)-$(uname -m).sh -b -p /opt/miniforge3 -s ; \
    rm -rf ./Miniforge3-*
ENV PATH /opt/miniforge3/bin:$PATH

COPY environment.yml .
RUN mamba install -y --file environment.yml && \
    mamba install -c conda-forge -c bioconda -y \
    colabfold=1.5.5 --no-deps && \
    mamba clean -afy

RUN pip uninstall jax jaxlib -y && \
    python3 -m pip install --no-cache-dir https://github.com/ROCm/jax/releases/download/rocm-jax-v0.4.34/jaxlib-0.4.34-cp310-cp310-manylinux_2_28_x86_64.whl && \
    python3 -m pip install --no-cache-dir https://github.com/ROCm/jax/releases/download/rocm-jax-v0.4.34/jax_rocm60_pjrt-0.4.34-py3-none-manylinux_2_28_x86_64.whl https://github.com/ROCm/jax/releases/download/rocm-jax-v0.4.34/jax_rocm60_plugin-0.4.34-cp310-cp310-manylinux_2_28_x86_64.whl && \
    python3 -m pip install --no-cache-dir https://github.com/ROCm/jax/archive/refs/tags/rocm-jax-v0.4.34.tar.gz

# Download weights
RUN python3 -m colabfold.download
