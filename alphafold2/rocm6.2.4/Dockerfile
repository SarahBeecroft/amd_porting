FROM quay.io/pawsey/rocm-mpich-base:rocm6.2.4-mpich3.4.3-ubuntu24.04

# Use bash to support string substitution.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ROCm environment
ENV ROCM_RELEASE 6.2.4
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE
ENV PATH $ROCM_PATH/bin:$ROCM_PATH/llvm/bin:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROCM_PATH/lib:/opt/miniforge3/lib
ENV JAX_PLATFORMS "rocm,cpu"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update --quiet \
    && apt-get install --no-install-recommends --yes --quiet \
        build-essential \
        cmake \
        git \
        hmmer \
        kalign \
        tzdata \
        wget \
		clang \
        doxygen \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove --yes \
    && apt-get clean

WORKDIR /opt

# Clone alphafold 
ENV ALPHAFOLD_PATH /app/alphafold
RUN set -eux ; \
    git clone --branch v2.3.2 https://github.com/google-deepmind/alphafold.git $ALPHAFOLD_PATH ; \
    cd $ALPHAFOLD_PATH ; \
    sed -i 's#CUDA#OpenCL#g' alphafold/relax/amber_minimize.py ; \
    sed -i 's#HIP#OpenCL#g' alphafold/relax/amber_minimize.py ; \
    cd $ALPHAFOLD_PATH/alphafold/common ; \
    curl -LO https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

#HHSUITE#
#RUN mkdir /opt/hhsuite && \
#    cd /opt/hhsuite && \
#    wget https://github.com/soedinglab/hh-suite/releases/download/v3.3.0/hhsuite-3.3.0-SSE2-Linux.tar.gz && \
#    tar xvfz hhsuite-3.3.0-SSE2-Linux.tar.gz && \
#    rm hhsuite-3.3.0-SSE2-Linux.tar.gz
#ENV PATH /opt/hhsuite/bin:/opt/hhsuite/scripts:$PATH

# Install miniforge (mamba)
RUN set -eux ; \
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" ; \
    bash Miniforge3-$(uname)-$(uname -m).sh -b -p /opt/miniforge3 -s ; \
    rm -rf ./Miniforge3-*
ENV PATH /opt/miniforge3/bin:$PATH

RUN mamba install -y -c conda-forge -c bioconda \
    python=3.11 \
    pdbfixer==1.9 \
    bioconda::hhsuite
    
RUN mamba install -y -c streamhpc -c conda-forge --strict-channel-priority openmm-hip==8.0.0 && \
    mamba clean -afy

# Install pip packages.
COPY requirements.txt /app/alphafold/requirements.txt
RUN pip3 install -r /app/alphafold/requirements.txt --no-cache-dir --root-user-action=ignore --break-system-packages && \
    pip uninstall -y jax jaxlib --break-system-packages && \
    python3 -m pip install --no-cache-dir --root-user-action=ignore --break-system-packages https://github.com/ROCm/jax/releases/download/rocm-jax-v0.4.34/jaxlib-0.4.34-cp311-cp311-manylinux_2_28_x86_64.whl && \
    python3 -m pip install --no-cache-dir --root-user-action=ignore --break-system-packages https://github.com/ROCm/jax/releases/download/rocm-jax-v0.4.34/jax_rocm60_pjrt-0.4.34-py3-none-manylinux_2_28_x86_64.whl https://github.com/ROCm/jax/releases/download/rocm-jax-v0.4.34/jax_rocm60_plugin-0.4.34-cp311-cp311-manylinux_2_28_x86_64.whl && \
    python3 -m pip install --no-cache-dir --root-user-action=ignore --break-system-packages https://github.com/ROCm/jax/archive/refs/tags/rocm-jax-v0.4.34.tar.gz

# Fix OpenMM imports in AlphaFold
RUN find /app/alphafold -type f -name "*.py" -exec sed -i \
    -e 's/from simtk\.openmm/from openmm/g' \
    -e 's/from simtk import openmm/import openmm/g' \
    -e 's/import simtk\.openmm/import openmm/g' \
    -e 's/simtk\.openmm\./openmm./g' \
    {} +

# Fix the specific internal import and  update any unit references
RUN sed -i 's/from simtk.openmm.app.internal.pdbstructure import PdbStructure/from openmm.app.internal.pdbstructure import PdbStructure/g' \
    /app/alphafold/alphafold/relax/amber_minimize.py && \
	find /app/alphafold -type f -name "*.py" -exec sed -i \
    's/simtk\.unit/openmm.unit/g' {} +
RUN mamba clean -afy
WORKDIR /app/alphafold
