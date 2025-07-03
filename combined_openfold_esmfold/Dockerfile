FROM rocm/pytorch:rocm6.2.2_ubuntu20.04_py3.9_pytorch_release_2.2.1

RUN apt-get update && \
    apt install apt-transport-https -y && \
    apt-get install -y \
	build-essential \
	wget \
	git \
	libxml2 \	
    aria2 \
    gcc \
    g++ \
    doxygen \
    autoconf \
    rccl \
    liblapack-dev \
    libopenblas-dev \
	&& \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

#
# ROCm environment
#
ENV ROCM_RELEASE 6.2.2
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE
ENV PATH $ROCM_PATH/bin:$ROCM_PATH/llvm/bin:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROCM_PATH/lib

#
# Mark RCCL as non-debug - this can be overriden by RCCL debug build. 
#
ENV RCCL_DEBUG 0
ENV HIP_PLATFORM=amd
ENV PYTORCH_ROCM_ARCH=gfx90a

RUN pip install --no-cache-dir \
biopython \
scipy \
wandb \
modelcif==0.7 \
swig>=3.0.5 \
ml-collections \
dm-tree \
pytorch-lightning \
deepspeed==0.16.0 \
pandas \
numpy==1.21.2 \
PyYAML \
requests \
tqdm \
typing-extensions \
wandb==0.12.21 


## Install HMMER 
WORKDIR /opt
RUN wget http://eddylab.org/software/hmmer/hmmer-3.3.2.tar.gz && \
    tar -xzf hmmer-3.3.2.tar.gz && \
    cd hmmer-3.3.2 && \
    ./configure && \
    make -j4 && \
    make install && \
    cd /opt && \
    rm -rf hmmer-3.3.2 hmmer-3.3.2.tar.gz

# Install Kalign2 
WORKDIR /opt
RUN mkdir kalign2 && \
    cd kalign2 && \
    wget http://msa.sbc.su.se/downloads/kalign/current.tar.gz && \
    tar -xzf current.tar.gz && \
    ./configure && \
    make && \
    make install && \
    cd /opt && \
    rm -rf current.tar.gz

# Install MMseqs2 
WORKDIR /opt
RUN git clone https://github.com/soedinglab/MMseqs2.git && \
    cd MMseqs2 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    make install && \
    cd /opt && \
    rm -rf MMseqs2

#Install pdbfixer 
WORKDIR /opt
RUN wget https://github.com/openmm/pdbfixer/archive/refs/tags/1.9.tar.gz && \
    tar xzvf 1.9.tar.gz && \
    rm 1.9.tar.gz && \
    cd pdbfixer-1.9 && \
    python setup.py install

#HHSUITE#
WORKDIR /opt
RUN mkdir /opt/hhsuite && \
    cd /opt/hhsuite && \
    wget https://github.com/soedinglab/hh-suite/releases/download/v3.3.0/hhsuite-3.3.0-SSE2-Linux.tar.gz && \
    tar xvfz hhsuite-3.3.0-SSE2-Linux.tar.gz && \
    rm hhsuite-3.3.0-SSE2-Linux.tar.gz
ENV PATH /opt/hhsuite/bin:/opt/hhsuite/scripts:$PATH

RUN conda install -y -c conda-forge -c bioconda streamhpc::openmm-hip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install

# Install OpenFold
WORKDIR /opt
RUN git clone https://github.com/aqlaboratory/openfold.git --branch v1.0.1
WORKDIR /opt/openfold
# Download folding resources
RUN wget --no-check-certificate -P openfold/resources \
    https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Certain tests need access to this file
RUN mkdir -p tests/test_data/alphafold/common && \
    ln -rs openfold/resources/stereo_chemical_props.txt tests/test_data/alphafold/common
RUN bash scripts/download_openfold_params.sh openfold/resources
RUN bash scripts/download_alphafold_params.sh openfold/resources
# Decompress test data
RUN gunzip tests/test_data/sample_feats.pickle.gz

WORKDIR /opt/openfold
COPY nocuda_setup.py .
RUN python nocuda_setup.py install && rm /opt/openfold/openfold/utils/kernel/attention_core.py
COPY amd_attention_core.py openfold/utils/kernel/attention_core.py
COPY amd_attention_core.py /opt/conda/envs/py_3.9/lib/python3.9/site-packages/openfold-1.0.1-py3.9.egg/openfold/utils/kernel/attention_core.py
COPY openfold_structure_module.py /opt/openfold/openfold/model/structure_module.py
COPY esmfold_structure_module.py /opt/conda/envs/py_3.9/lib/python3.9/site-packages/openfold-1.0.1-py3.9.egg/openfold/model/structure_module.py

# Install ESMFold dependencies
RUN	/opt/conda/envs/py_3.9/bin/pip install --no-cache-dir git+https://github.com/facebookresearch/esm.git
RUN	/opt/conda/envs/py_3.9/bin/pip install --no-cache-dir \
    matplotlib \ 
    einops \
    omegaconf \
    biotite
RUN pip install "scipy<=1.15.0" --no-cache-dir --force-reinstall 
RUN pip install biopython==1.79 --no-cache-dir --force-reinstall 
RUN pip install numpy==1.23.5 --no-cache-dir --force-reinstall
RUN sed -i 's/deepspeed\.utils\.is_initialized()/deepspeed.comm.comm.is_initialized()/g' /opt/conda/envs/py_3.9/lib/python3.9/site-packages/openfold-1.0.1-py3.9.egg/openfold/model/primitives.py
