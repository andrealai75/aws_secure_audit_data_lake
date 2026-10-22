# AWS Secure Audit Data Lake (Terraform Sandbox)

A minimal, low-cost architectural blueprint built using Terraform to practice fine-grained data governance, centralized access management, and serverless analytics. 

The core objective is to model a real-world compliance scenario: ingesting financial/sensitive logs, applying row/column level restrictions, and enforcing strict cryptographic controls using a zero-trust model without provisioning any persistent or expensive infrastructure.

## 💰 Cost Optimization Guardrails

Designed specifically to run inside a personal AWS account for under **\$0.30**, the code incorporates the following mechanisms:
1.  **S3 Bucket Keys Enabled:** Minimises KMS cryptographic handshake frequency, reducing standard API request request volumes and costs by up to 99%.
2.  **Serverless Metadata Declaration:** Provisions the AWS Glue Catalog Table directly via declarative Terraform codeblocks—completely avoiding the compute costs associated with running active AWS Glue Crawlers.
3.  **Athena Workgroup Cutoffs:** Restricts query data scanning thresholds using a hard server-side limit (`bytes_scanned_cutoff_per_query`) set to **10MB** to isolate the account from runaway analytics bills.

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
In the Athena console select the secure-audit-workgroup workshop

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
