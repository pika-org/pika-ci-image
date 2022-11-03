# Copyright (c) 2020 ETH Zurich
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

ARG BASE_IMAGE

FROM $BASE_IMAGE

ENV DEBIAN_FRONTEND=noninteractive

# Install ROCm
RUN wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add - && \
    echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | \
    tee /etc/apt/sources.list.d/rocm.list && apt-get update -qq && \
    apt-get install -qq -y rocm-dev rocm-libs hipblas && \
    rm -rf /var/lib/apt/lists/*

ENV ROCM_PATH=/opt/rocm
ENV PATH="${ROCM_PATH}/bin:${ROCM_PATH}/rocprofiler/bin:${ROCM_PATH}/opencl/bin:${PATH}"

# Install a newer CMake
RUN cd /tmp && \
    curl --output cmake.tar.gz \
    --location https://github.com/Kitware/CMake/releases/download/v3.22.0/cmake-3.22.0-Linux-x86_64.tar.gz && \
    (echo "dc73115520d13bb64202383d3df52bc3d6bbb8422ecc5b2c05f803491cb215b0" cmake.tar.gz | sha256sum --check) && \
    tar xvf cmake.tar.gz --strip-components=1 --directory /usr/local && \
    rm -rf cmake.tar.gz && \
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
    rm -rf /tmp/fmt
