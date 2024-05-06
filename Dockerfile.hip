# Copyright (c) 2020 ETH Zurich
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

ARG BASE_IMAGE

FROM $BASE_IMAGE

ENV DEBIAN_FRONTEND=noninteractive

# Install ROCm
# (using rocm-dev5.3.2 instead of rocm-dev as rocm-dev dependencies are broken)
RUN rocm_version=5.3.2 && apt-get update && apt-get install -y wget gnupg && \
    wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add - && \
    echo "deb [arch=amd64] https://repo.radeon.com/rocm/apt/${rocm_version}/ jammy main" | \
    tee /etc/apt/sources.list.d/rocm.list && apt-get update -qq && \
    apt-get install -y rocm-dev${rocm_version} rocm-libs${rocm_version} \
    rocblas${rocm_version} && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

ENV ROCM_PATH=/opt/rocm
ENV PATH="${ROCM_PATH}/bin:${ROCM_PATH}/rocprofiler/bin:${ROCM_PATH}/opencl/bin:${PATH}"

# Install a newer CMake
RUN cd /tmp && \
    # Install whip
    cd /tmp && \
    git clone https://github.com/eth-cscs/whip.git && \
    cd whip && \
    cmake -DWHIP_BACKEND=HIP . && \
    make install && \
    cd /tmp && \
    rm -rf /tmp/whip && \
    # Install fmt (NOTE: fmt is installed in newer versions of the base image,
    # but not in the currently used version of the base image)
    cd /tmp && \
    git clone https://github.com/fmtlib/fmt.git && \
    cd fmt && \
    git checkout 9.1.0 && \
    cmake -DBUILD_SHARED_LIBS=ON . && \
    make install && \
    cd /tmp && \
    rm -rf /tmp/fmt && \
    # Installing spdlog here separately since the required base image for the
    # HIP image does not yet have spdlog installed
    cd /tmp && \
    git clone https://github.com/gabime/spdlog.git && \
    cd spdlog && \
    git checkout v1.11.0 && \
    cmake -DBUILD_SHARED_LIBS=ON -DSPDLOG_FMT_EXTERNAL=ON . && \
    make install && \
    cd /tmp && \
    rm -rf /tmp/spdlog
