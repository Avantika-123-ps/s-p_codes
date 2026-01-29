# Multiple Bucket Creation

This repository manages the automated creation of Google Cloud Storage (GCS) buckets and Log Sinks using Terraform. It utilizes a CSV-driven approach to define resources and a branch-based strategy for multi-environment deployment.

## Project Structure

```
multiple_bucket_creation/
├── .github/workflows/
│   └── pipeline.yml       # GitHub Actions workflow for CI/CD
├── envs/
│   ├── nonprod/           # Non-Production environment configuration
│   │   ├── buckets.csv    # CSV defining non-prod buckets
│   │   ├── main.tf        # Entry point for non-prod
│   │   └── ...
│   └── prod/              # Production environment configuration
│       ├── buckets.csv    # CSV defining prod buckets
│       └── ...
├── modules/
│   └── log_infrastructure/ # Reusable Terraform module for logging
└── README.md              # Project documentation
```

## Branching & Deployment Strategy

We follow a GitOps workflow where branches map directly to GCP environments.

- **`dev` Branch** → **NonProd Environment**
  - Code pushes to the `dev` branch automatically trigger Terraform deployment to the Non-Production GCP project.
  - Used for testing and validation.

- **`main` Branch** → **Prod Environment**
  - Merges into the `main` branch automatically trigger Terraform deployment to the Production GCP project.
  - Strictly controlled via Pull Requests.

### Architecture Diagram

The following diagram illustrates the branching strategy and code deployment flow:

![Branching Strategy](branching_strategy.png)

## Workflow Details

1. **Feature Development**:
   - Developers work on feature branches and merge into `dev`.
   - The pipeline runs `terraform plan` and `terraform apply` in `envs/nonprod`.

2. **Production Release**:
   - Once verified in NonProd, a Pull Request is raised from `dev` to `main`.
   - Merging to `main` triggers the pipeline to run `terraform apply` in `envs/prod`.

## Resource Management (CSV)

Buckets are defined in `buckets.csv` files within each environment folder. This allows for bulk management without modifying Terraform code directly.

**Format:**
```csv
project_id,prefix,name,location,storage_class,versioning,retention_policy,labels,logging_bucket,logging_prefix
```

## VS Code & GitHub SSH Integration

To integrate Git with VS Code using SSH keys, follow these steps:

1.  **Generate an SSH Key** (if you haven't already):
    Open your terminal and run:
    ```bash
    ssh-keygen -t ed25519 -C "your-email@example.com"
    ```
    - Press **Enter** to accept the default file location.
    - Set a passphrase (recommended) or press **Enter** for none.

2.  **Add Key to SSH Agent**:
    Start the agent and add your key:
    ```bash
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    ```

3.  **Add Public Key to GitHub**:
    - Copy the public key:
      ```bash
      cat ~/.ssh/id_ed25519.pub
      ```
    - Go to **GitHub** -> **Settings** -> **SSH and GPG keys** -> **New SSH key**.
    - Paste the key and save.

4.  **Configure Remote URL in VS Code**:
    If you cloned with HTTPS, switch to SSH:
    ```bash
    git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
    ```

5.  **Verify Connection**:
    ```bash
    ssh -T git@github.com
    ```
    You should see: "Hi USERNAME! You've successfully authenticated..."