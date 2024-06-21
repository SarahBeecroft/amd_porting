FROM  quay.io/pawsey/rocm-mpich-base:rocm6.0.2-mpich3.4.3-ubuntu22

RUN apt-get update && \
    apt install apt-transport-https curl gnupg -y && \
    curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg && \
    mv bazel-archive-keyring.gpg /usr/share/keyrings && \
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8 | sudo tee /etc/apt/sources.list.d/bazel.list && \
    apt-get install -y build-essential wget aria2 git cmake gcc-10 clang gfortran zlib1g-dev numactl gawk patch tar autoconf automake libtool libjson-c-dev graphviz libncurses-dev nano xz-utils binutils doxygen && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

#
# Alphafold info
#
ENV PYTHON_VERSION='3.10'
#ENV JAX_VERSION='0.4.14'
ENV JAX_VERSION='0.4.29'
ENV ALPHAFOLD_VERSION='69afc4d'
ENV ARIA2_VERSION='1.36.0'
ENV HHSUITE_VERSION='3.3.0'
ENV OPENMM_VERSION='8.1.1'
ENV OPENMM_HIP_VERSION='1631e8d'
ENV JAX_PLATFORMS "rocm,cpu"
#
# ROCm environment
#
ENV ROCM_RELEASE 6.0.2
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE
ENV PATH $ROCM_PATH/bin:$ROCM_PATH/llvm/bin:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROCM_PATH/lib
#
# Mark RCCL as non-debug - this can be overriden by RCCL debug build. 
#
ENV RCCL_DEBUG 0

#
# Install miniforge (mamba)
#

RUN set -eux ; \
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" ; \
    bash Miniforge3-$(uname)-$(uname -m).sh -b -p /opt/miniforge3 -s ; \
    rm -rf ./Miniforge3-*
ENV PATH /opt/miniforge3/bin:$PATH

ENV CC gcc
ENV CXX g++

#
# Install hh-suite.
#
ARG HHSUITE_VERSION
ENV HHSUITE_PATH /opt/hh-suite
RUN set -eux ; \
  mkdir -p /opt/builds ; \
  git clone --branch v$HHSUITE_VERSION https://github.com/soedinglab/hh-suite.git /opt/builds/hh-suite ; \
  mkdir /opt/builds/hh-suite/build ; \
  cd /opt/builds/hh-suite/build ; \
  cmake -DCMAKE_INSTALL_PREFIX=$HHSUITE_PATH .. ; \
  make -j   ; \
  make -j install  ; \
  rm -rf /opt/builds
  
#
# Install mamba environment
# 
ARG PYTHON_VERSION
RUN set -eux ; \
  mamba install -y \
  python=$PYTHON_VERSION \
    swig \
    numpy==1.24.3 \
    Cython \
    pandas==2.0.3 ; \
  mamba install -y -c conda-forge \
    dm-tree==0.1.8 \
    pdbfixer==1.9 ; \
  mamba install -y -c bioconda \
    kalign2 ; \
  mamba install -y streamhpc::openmm-hip
RUN pip install \
    ml-collections==0.1.0 \
    dm-haiku==0.0.12 \
    hmmer \
    absl-py==1.0.0 \
    mock \
    chex==0.0.7 \
    immutabledict==2.0.0 \
    scipy==1.11.1 \
    biopython==1.79 \
    typing-extensions \
    tensorflow \
    --no-cache-dir

#
# Install JAX
#
RUN python3 -m pip install https://github.com/ROCm/jax/releases/download/rocm-jaxlib-v0.4.28/jaxlib-0.4.28+rocm602-cp310-cp310-manylinux2014_x86_64.whl --no-cache-dir && \
  python3 -m pip install https://github.com/ROCm/jax/archive/refs/tags/rocm-jaxlib-v0.4.28.tar.gz --no-cache-dir

#
# Clone alphafold 
#
ARG ALPHAFOLD_VERSION
ENV ALPHAFOLD_PATH /opt/alphafold
RUN set -eux ; \
  git clone https://github.com/deepmind/alphafold $ALPHAFOLD_PATH ; \
  \
  cd $ALPHAFOLD_PATH ; \
  git checkout -b mydev $ALPHAFOLD_VERSION ; \
  sed -i 's#CUDA#HIP#g' alphafold/relax/amber_minimize.py ; \
  \
  cd $ALPHAFOLD_PATH/alphafold/common ; \
  curl -LO https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

RUN set -eux ; \
  rm /opt/miniforge3/lib/libstdc++.so* ; \
  ln -s /usr/lib64/libstdc++.so* /opt/miniforge3/lib

WORKDIR /opt/alphafold
