# Project: Three‑Tier App with Terraform + Jenkins

This repository provisions a **Database → Backend → Frontend** stack using **Terraform (Docker provider)** and ships a **Jenkins pipeline** for CI/CD.

> **Heads‑up:** The **initial commit** contains the base **Terraform‑only configuration** to provision Docker networks, volumes, and containers, and to bring up images directly via Terraform.
>
> The **current, up‑to‑date commit** adds **Jenkins automation**, where Jenkins triggers builds and orchestrates Terraform to provision and manage the infrastructure. In this flow, **Terraform handles both image builds and container provisioning**.

---

## What This Commit Provides (Two‑Step Config)

1. **Terraform structure & conventions** (filenames, variables, outputs, destroy flow) for building images and provisioning containers.
2. **Jenkins pipeline automation** that integrates with Terraform for builds, deployments, and health checks.

> You will create the following files in your project root:
>
> * `main.tf` — Docker provider + network/volume/container resources, builds images
> * `variables.tf` — inputs for images, ports, credentials, etc.
> * `outputs.tf` — frontend URL, backend URL, container IDs
> * `.tfvars.example` — template for environment values and secrets (do **not** commit real secrets)
> * `Jenkinsfile` — declarative pipeline that triggers Terraform to build images and provision resources

---

## Step 1 — Terraform: Infrastructure, Build & Runtime

Terraform is responsible for:

* Creating a **private internal Docker network** for inter‑tier traffic
* Defining **persistent volumes** for database data
* Building **Docker images** for backend and frontend
* Provisioning **containers in dependency order**: **DB → Backend → Frontend**
* Emitting **output values** (frontend URL, backend API URL, container names/IDs)

### Files you add

* **`main.tf`**

  * Configure Docker provider
  * `docker_network` resource with `internal = true` (e.g., `app_internal`)
  * `docker_volume` resources (e.g., `db_data`)
  * `docker_image` resources for backend and frontend builds
  * `docker_container` resources for db, backend, frontend

    * `depends_on` to enforce DB → Backend → Frontend
    * `networks_advanced` to attach to `app_internal`
* **`variables.tf`**

  * Define variables for image names/tags, ports, env vars, secrets, resource names (network, volumes)
* **`outputs.tf`**

  * Output `frontend_url`, `backend_api_url`, and container identifiers
* **`.tfvars.example`**

  * Provide **placeholders** like:

    * `db_image`, `db_user`, `db_password`, `db_name`
    * `backend_dockerfile`, `backend_port`
    * `frontend_dockerfile`, `frontend_port`
    * `internal_network_name = "app_internal"`
    * `db_volume_name = "db_data"`

### Commands

```bash
terraform init
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars -auto-approve
terraform output
```

### Destroy (Clean Removal)

```bash
terraform destroy -var-file=env/dev.tfvars -auto-approve
```

---

## Step 2 — Jenkins Pipeline (CI/CD)

The pipeline lives in a **`Jenkinsfile`** at the repo root and is triggered **on push** or **manually**.

### Stages

1. **Checkout** — Pull latest code
2. **Build & Provision** — Jenkins calls Terraform, which builds Docker images and provisions containers
3. **Health Checks** — Verify DB, Backend, and Frontend are alive
4. **Post‑Deployment Notification** — Slack/email/console

### Credentials & Secrets

* Store DB credentials and any tokens in **Jenkins Credentials Manager**
* Inject as **environment variables** in the pipeline
* Pass them securely into Terraform (`-var-file`)

### Typical Jenkinsfile actions (no code pasted)

* `withCredentials { ... }` to map secrets → env vars
* `sh 'terraform init'`
* `sh 'terraform apply -var-file=${TF_VARS_FILE} -auto-approve'`
* **Health checks**: curl `http://backend:PORT/health`, `http://frontend:PORT/health`, and DB connect test
* On success/failure: post Slack/email or echo to console

---

## Demo

* `test.dhanu.cloud`

---

## See Also

* For a Terraform‑only example without Jenkins, **visit the repository’s *initial commit***.
* For Jenkins‑driven automation where Terraform also builds the images, see this **current commit**.