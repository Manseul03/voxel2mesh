# 1. NVIDIA CUDA Devel 이미지를 베이스로 사용 (컴파일이 필요한 라이브러리 대응용)
# PyTorch 1.6과 호환되는 CUDA 10.2 버전을 선택했습니다.
FROM nvidia/cuda:10.2-devel-ubuntu18.04

# 2. 시스템 기본 도구 설치 (Miniconda 설치 및 소스 관리용)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    git \
    libgl1-mesa-glx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Miniconda 설치
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# 4. Conda 환경 변수 설정
ENV PATH=$CONDA_DIR/bin:$PATH

# 5. 작업 디렉토리 설정 및 environment.yaml 복사
WORKDIR /app
COPY environment.yaml .

# 6. Conda 환경 생성 (yaml 파일에 정의된 python 3.6.9, pytorch 1.6.0 등 설치)
# --name 뒤의 'v2m_env'는 원하시는 환경 이름으로 바꾸셔도 됩니다.
RUN conda env create -f environment.yaml

# 7. 기본 쉘 설정 및 환경 활성화
# 이후 RUN 명령어가 conda 환경 내부에서 실행되도록 설정합니다.
SHELL ["conda", "run", "-n", "v2m_env", "/bin/bash", "-c"]

# 8. 프로젝트 소스 복사
COPY /app/voxel2mesh .

# 9. 컨테이너 실행 시 기본 실행 명령어 (v2m_env 환경에서 실행)
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "v2m_env", "python", "train.py"]