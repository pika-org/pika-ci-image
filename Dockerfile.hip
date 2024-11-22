# Copyright (c) 2020 ETH Zurich
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

ARG BASE_IMAGE

FROM $BASE_IMAGE

ENV DEBIAN_FRONTEND=noninteractive

# Install ROCm
# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/native-install/ubuntu.html
RUN apt-get update && apt-get install -y wget gnupg && \
    mkdir --parents --mode=0755 /etc/apt/keyrings && \
    wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.2.2/ubuntu noble main" \
        | tee /etc/apt/sources.list.d/amdgpu.list && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.2.2 noble main" \
        | tee --append /etc/apt/sources.list.d/rocm.list && \
    echo 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' \
        | tee /etc/apt/preferences.d/rocm-pin-600 && \
    cat /etc/apt/preferences.d/rocm-pin-600 && \
    apt-get update -qq && \
    apt-get install -y rocm-dev rocblas-dev rocsolver-dev && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

ENV ROCM_PATH=/opt/rocm
ENV PATH="${ROCM_PATH}/bin:${PATH}"

RUN cd /tmp && \
    # Install whip
    cd /tmp && \
    git clone https://github.com/eth-cscs/whip.git && \
    cd whip && \
    cmake -DWHIP_BACKEND=HIP . && \
    make install && \
    cd /tmp && \
    rm -rf /tmp/whip
