# AWS Secure Audit Data Lake (Terraform Sandbox)

A minimal, low-cost architectural blueprint built using Terraform to practice fine-grained data governance, centralized access management, and serverless analytics. This project was developed as a hands-on learning laboratory in preparation for the **AWS Certified Security – Specialty** exam.

The core objective is to model a real-world compliance scenario: ingesting financial/sensitive logs, applying row/column level restrictions, and enforcing strict cryptographic controls using a zero-trust model without provisioning any persistent or expensive infrastructure.

## 🏗️ Architecture Overview

## 🔒 Security & Exam-Focused Controls

This architecture explicitly implements several high-yield domains tested on the AWS Security Specialist exam:

*   **Centralised Data Governance:** Shifts data controls away from standard S3 Bucket/IAM User policies by registering the storage layer with **AWS Lake Formation**. S3 access is decoupled and managed using a zero-trust structural delegation model.
*   **Fine-Grained Access Control (FGAC):** Provisions two mock personas (`AuditAdmin` and `DataAnalyst`) to demonstrate column-level security. The Analyst user is restricted via `table_with_columns` permissions, rendering sensitive fields (`customer_name` and `credit_card_hash`) invisible during query runtimes without altering the raw underlying data files.
*   **Dynamic Session Auditing:** Configures the Lake Formation Custom Service Role with `sts:SetContext` inside its trust policy. This enforces end-to-end user identity propagation down to CloudTrail logs during serverless resource delegation hooks.
*   **Cryptographic Boundaries:** Enforces Server-Side Encryption (**SSE-KMS**) using a Customer Managed Key (CMK) configured with a strict 7-day minimum deletion retention window. 
*   **Bucket-Level Hardening:** Deploys an explicit `Deny` condition inside the S3 bucket policy tracking `aws:SecureTransport = false` to eliminate unencrypted data transit vectors across the storage infrastructure.

## 💰 Cost Optimization Guardrails

Designed specifically to run inside a personal AWS account for under **\$0.30**, the code incorporates the following mechanisms:
1.  **S3 Bucket Keys Enabled:** Minimises KMS cryptographic handshake frequency, reducing standard API request request volumes and costs by up to 99%.
2.  **Serverless Metadata Declaration:** Provisions the AWS Glue Catalog Table directly via declarative Terraform codeblocks—completely avoiding the compute costs associated with running active AWS Glue Crawlers.
3.  **Athena Workgroup Cutoffs:** Restricts query data scanning thresholds using a hard server-side limit (`bytes_scanned_cutoff_per_query`) set to **10MB** to isolate the account from runaway analytics bills.

## 📁 Repository Structure

```text
.
├── Taskfile.yml                        # Task runner script entries
└── infrastructure                      # Main Terraform Workspace
    ├── athena_workgroup.tf             # Enforced encryption & data caps
    ├── current_user.tf                 # Dynamic identity caller context 
    ├── data                            # Mock dataset directory
    │   └── ticket_sales.csv            # Source data containing sensitive hashes
    ├── data.tf                         # Automated S3 file object uploader
    ├── glue_catalog_database.tf        # Isolated database & legacy permission purge
    ├── glue_catalog_table.tf           # Oracle External Table style mapping
    ├── kms.tf                          # CMK configuration & service policies
    ├── lake_formation.tf               # Data lake settings & registration links
    ├── lake_formation_permissions.tf   # Fine-grained RBAC permissions mapping
    ├── lake_formation_service_role.tf  # Custom service role wrapper 
    ├── locals.tf                       # Dynamic configuration variables
    ├── provider.tf                     # AWS explicit configuration limits
    ├── s3_bucket.tf                    # Locked down encrypted object bucket
    └── users.tf                        # Test IAM security personas
```

## 🚀 Deployment & Validation

### Prerequisites
*   Terraform installed (`>= 1.0.0`)
*   AWS CLI configured with appropriate administrator deployment credentials

### 1. Initialize and Apply the Infrastructure
Navigate to the infrastructure directory and execute the provisioning lifecycle:
```bash
task init
task validate
task plan
task apply
```

### 2. Verify Security Policy Personas
Once the deployment finishes and the `ticket_sales.csv` is automatically uploaded into your data lake, open the **Amazon Athena Console** and select the `secure-audit-workgroup` workgroup to run tests:

#### Test A: Execute Query as `AuditAdmin`
```sql
SELECT * FROM audit_db.ticket_logs;
```
*Expected Result:* Full visibility. Returns all columns including plaintext `customer_name` and `credit_card_hash`.

#### Test B: Execute Query as `DataAnalyst`
```sql
SELECT * FROM audit_db.ticket_logs;
```
*Expected Result:* Request Blocked or Auto-Masked. Because the Analyst does not hold column privileges for all fields, standard full table scans are rejected or fields are withheld.

To execute successfully under the analyst persona, explicitly request authorized columns only:
```sql
SELECT ticket_id, event_name, price FROM audit_db.ticket_logs;
```

## 🧼 Teardown
To destroy all created resources and stop incurring billing fees for the active KMS key retention period, execute:
```bash
task destroy
```
*(Note: Due to the AWS KMS pending deletion configuration constraints, the CMK will remain in a pending deletion status for 7 days, costing roughly $0.24 total before automated erasure).*
