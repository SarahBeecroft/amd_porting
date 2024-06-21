FROM quay.io/pawsey/rocm-mpich-base:rocm6.0.2-mpich3.4.3-ubuntu22

RUN apt-get update && \
    apt install apt-transport-https curl gnupg sed -y && \
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
ENV ALPHAFOLD_VERSION='69afc4d'
ENV HHSUITE_VERSION='3.3.0'

#
# ROCm environment
#
ENV ROCM_RELEASE 6.0.2
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE
ENV PATH $ROCM_PATH/bin:$ROCM_PATH/llvm/bin:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROCM_PATH/lib
#
#
# Mark RCCL as non-debug - this can be overriden by RCCL debug build. 
#
ENV RCCL_DEBUG 0

#
# Install miniforge
#
RUN set -eux ; \
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" ; \
    bash Miniforge3-$(uname)-$(uname -m).sh -b -p /opt/miniforge3 -s ; \
    rm -rf ./Miniforge3-*
ENV PATH /opt/miniforge3/bin:$PATH

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
  

#Install mamba environment
 
ARG PYTHON_VERSION
RUN mamba install -y -c conda-forge -c bioconda \
    python=$PYTHON_VERSION \
    swig \
    numpy==1.24.3 \
    Cython \
    pandas==2.0.3 \
    dm-tree==0.1.8 \
    pdbfixer==1.9 \
    kalign2=2.04 \
    mmseqs2=15.6f452 \
    streamhpc::openmm-hip && \
    mamba clean -afy
RUN pip install \
    tensorflow \
    ml-collections==0.1.0 \
    dm-haiku==0.0.12 \
    hmmer \
    absl-py==1.0.0 \
    mock \
    chex==0.0.7 \
    immutabledict==2.0.0 \
    biopython==1.79 --no-cache-dir
    
#############
##COLABFOLD##
#############

ENV CURRENTPATH='/opt'
ENV COLABFOLDDIR="${CURRENTPATH}/localcolabfold"

RUN mkdir -p "${COLABFOLDDIR}" ; \ 
    cd "${COLABFOLDDIR}"

# install ColabFold and Jaxlib
RUN pip install --no-warn-conflicts \
    "colabfold[alphafold-without-jax] @ git+https://github.com/sokrypton/ColabFold" --no-cache-dir ; \
    pip install "colabfold[alphafold]" --no-cache-dir ; \
    pip install --upgrade tensorflow --no-cache-dir

# Download the updater
RUN wget -qnc -O "$COLABFOLDDIR/update_linux.sh" \
    https://raw.githubusercontent.com/YoshitakaMo/localcolabfold/main/update_linux.sh ;\
    chmod +x "$COLABFOLDDIR/update_linux.sh" ; \
    cd /opt/miniforge3/lib/python3.10/site-packages/colabfold && sed -i -e "s#from matplotlib import pyplot as plt#import matplotlib\nmatplotlib.use('Agg')\nimport matplotlib.pyplot as plt#g" plot.py && sed -i -e "s#appdirs.user_cache_dir(__package__ or \"colabfold\")#\"${COLABFOLDDIR}/colabfold\"#g" download.py && \
    rm -rf __pycache__

# Download weights
RUN python3 -m colabfold.download


# Install JAX
RUN python3 -m pip install https://github.com/ROCm/jax/releases/download/rocm-jaxlib-v0.4.28/jaxlib-0.4.28+rocm602-cp310-cp310-manylinux2014_x86_64.whl --no-cache-dir && \
  python3 -m pip install https://github.com/ROCm/jax/archive/refs/tags/rocm-jaxlib-v0.4.28.tar.gz --no-cache-dir
ENV JAX_PLATFORMS "rocm,cpu"

WORKDIR ${COLABFOLDDIR}
