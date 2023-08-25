#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

# read -p "Enter the URL from email: " PRESIGNED_URL
# echo ""
# ALL_MODELS="7b"
# # read -p "Enter the list of models to download without spaces ($ALL_MODELS), or press Enter for all: " MODEL_SIZE
PRESIGNED_URL = "https://download2.llamameta.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoiaHFlbHBvZXZqMnhrbXFzbzFwN2ZoZXdoIiwiUmVzb3VyY2UiOiJodHRwczpcL1wvZG93bmxvYWQyLmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2OTMwMjMxNDB9fX1dfQ__&Signature=EPPcEYi9XdLfLLvi-BNRfztIfQcTbNVRU0pbSjKj-EOC5ksWKWZx3YBpVmK3p-QIAeO6xRBYs547EwUhha-BH6UF3hgL-fjW56H-7SQ5amWjVVDGT%7EII7PsiPfvTnQUAlQ3ogCQHr-0wgRsl0T12OtCXaKlGOMj%7EMuV%7ES8PrsxiOTvxVwBlclfRRZiYOLUq5DJKCoCUkgPBPtvLNskRliuicRqbXPQhqIxSSUPyUbvISWU4sNEXbbCmfAEQqd%7EsIvUfPofw2vW1AfqfOk7y97K-WjXu92xPdWzQ3%7EKnNcup7obumfAK3AOcpuU8n0Hp0rTYB5dyXd0Kgup%7E9mG9TJQ__&Key-Pair-Id=K15QRJLYKIFSLZ&Download-Request-ID=228008026496579"
TARGET_FOLDER="."             # where all files should end up
MODEL_SIZE="7b"
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE=$ALL_MODELS
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"

for m in ${MODEL_SIZE//,/ }
do
    case $m in
      7b)
        SHARD=0 ;;
      13b)
        SHARD=1 ;;
      34b)
        SHARD=3 ;;
      7b-Python)
        SHARD=0 ;;
      13b-Python)
        SHARD=1 ;;
      34b-Python)
        SHARD=3 ;;
      7b-Instruct)
        SHARD=0 ;;
      13b-Instruct)
        SHARD=1 ;;
      34b-Instruct)
        SHARD=3 ;;
      *)
        echo "Unknown model: $m"
        exit 1
    esac

    MODEL_PATH="CodeLlama-$m"
    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/tokenizer.model"
    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
done
