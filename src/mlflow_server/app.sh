#!/usr/bin/env bash
echo "Starting MLflow server..."

# Define o diretório onde os dados do MLflow serão armazenados
export BACKEND_STORE_URI=sqlite:///mlflow.db
export ARTIFACT_ROOT=./artifacts

# Executa o MLflow
mlflow server \
    --backend-store-uri $BACKEND_STORE_URI \
    --default-artifact-root $ARTIFACT_ROOT \
    --host 0.0.0.0 \
    --port 5002