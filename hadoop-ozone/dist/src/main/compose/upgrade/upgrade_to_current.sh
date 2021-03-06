#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script tests upgrade from a previous release to the current
# binaries.  Docker image with Ozone binaries is required for the
# initial version, while the snapshot version uses Ozone runner image.

set -e -o pipefail

COMPOSE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export COMPOSE_DIR

: "${OZONE_REPLICATION_FACTOR:=3}"
: "${OZONE_UPGRADE_FROM:="0.5.0"}"
: "${OZONE_VOLUME:="${COMPOSE_DIR}/data"}"

export OZONE_REPLICATION_FACTOR OZONE_UPGRADE_FROM OZONE_VOLUME

current_version=1.1.0

source "${COMPOSE_DIR}/testlib.sh"

create_data_dir

prepare_for_binary_image "${OZONE_UPGRADE_FROM}"
load_version_specifics "${OZONE_UPGRADE_FROM}"
first_run
unload_version_specifics

from=$(get_logical_version "${OZONE_UPGRADE_FROM}")
to=$(get_logical_version "${current_version}")
execute_upgrade_steps "$from" "$to"

prepare_for_runner_image
second_run

generate_report
