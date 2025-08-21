FROM rocm/dgl:dgl-2.4_rocm6.4_ubuntu24.04_py3.12_pytorch_release_2.4.1
RUN apt-get -q update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
	build-essential \
	git \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get autoremove -y \
	&& apt-get clean
	
WORKDIR /app
RUN git clone https://github.com/RosettaCommons/RFdiffusion.git --branch v1.1.0 --single-branch

RUN pip install -q --no-cache-dir \
    e3nn==0.5.6 \
    wandb==0.17.0 \
    decorator==5.1.0 \
    hydra-core==1.3.2 \
    pyrsistent==0.19.3 \
    icecream \
    hiredis \
    /app/RFdiffusion/env/SE3Transformer \
    && pip install --no-cache-dir /app/RFdiffusion --no-deps

RUN mkdir -p /opt/conda/envs/py_3.12/config/inference && \
    cp /app/RFdiffusion/config/inference/* /opt/conda/envs/py_3.12/config/inference
WORKDIR /app/RFdiffusion
ENV DGLBACKEND="pytorch"
ENV PATH="/opt/conda/envs/py_3.12/bin:$PATH"
ENV PYTHONPATH="/app/RFdiffusion:$PYTHONPATH"

RUN mkdir models && cd models && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/6f5902ac237024bdd0c176cb93063dc4/Base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/e29311f6f1bf1af907f9ef9f44b8328b/Complex_base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/60f09a193fb5e5ccdc4980417708dbab/Complex_Fold_base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/74f51cfb8b440f50d70878e05361d8f0/InpaintSeq_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/76d00716416567174cdb7ca96e208296/InpaintSeq_Fold_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/5532d2e1f3a4738decd58b19d633b3c3/ActiveSite_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/12fc204edeae5b57713c5ad7dcb97d39/Base_epoch8_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/f572d396fae9206628714fb2ce00f72e/Complex_beta_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/1befcb9b28e2f778f53d47f18b7597fa/RF_structure_prediction_weights.pt
