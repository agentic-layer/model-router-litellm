# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a containerized LiteLLM-based model router that acts as an egress API gateway for routing between different LLM providers (OpenAI, Gemini, etc.). The project uses the official LiteLLM Docker image with custom configuration files.

## Architecture

- **Base Image**: Uses `ghcr.io/berriai/litellm:main-stable` 
- **Configuration**: LiteLLM configs in `kustomize/` directory with two environments:
  - `base/`: Contains fake endpoint configuration for testing
  - `local/`: Production-ready config routing to OpenAI with wildcard model support
- **Deployment**: Kubernetes-based using Kustomize for configuration management
- **Port**: Service runs on port 4000

## Key Components

- `Dockerfile`: Simple container definition extending LiteLLM base image
- `kustomize/base/`: Base Kubernetes resources (deployment, service, config)
- `kustomize/local/`: Local/production overlay with ingress and OpenAI integration
- Configuration files define model routing and proxy settings

## Common Commands

### Docker Operations
```bash
# Build the Docker image
docker build -t agentic-layer/model-router-litellm .

# Run locally with environment variables
docker run -p 4000:4000 -e OPENAI_API_KEY=your_key_here agentic-layer/model-router-litellm
```

### Kubernetes Deployment
```bash
# Create required secret for OpenAI API key
kubectl create secret generic openai-api-key --from-literal=OPENAI_API_KEY=$OPENAI_API_KEY

# Deploy to local environment
kubectl apply -k kustomize/local/

# Deploy base configuration
kubectl apply -k kustomize/base/
```

### Testing the Deployment
```bash
# Test the proxy endpoint
curl http://litellm.127.0.0.1.sslip.io/chat/completions \
  -H "Content-Type: application/json" \
  -H 'Authorization: Bearer sk-1234' \
  -d '{
     "model": "gpt-4o-mini",
     "messages": [{"role": "user", "content": "Say this is a test!"}],
     "temperature": 0.7
   }'
```

## Configuration Details

### Model Routing
- Base config: Routes to fake endpoint for testing
- Local config: Uses wildcard (`"*"`) to route all models to OpenAI with `openai/*` prefix
- API keys sourced from environment variables (`os.environ/OPENAI_API_KEY`)

### Resource Limits
- Memory: 128Mi request, 512Mi limit
- CPU: 500m request, 2000m limit
- Health checks configured for both liveness and readiness probes

## Environment Variables

Required environment variables:
- `OPENAI_API_KEY`: Your OpenAI API key for model access

The application expects the API key to be provided via Kubernetes secrets in the `openai-api-key` secret.