# 1. Full Access for the Audit Admin User
resource "aws_lakeformation_permissions" "admin_table_access" {
  principal   = aws_iam_user.audit_admin.arn
  permissions = ["SELECT"]

  table {
    database_name = aws_glue_catalog_database.audit_db.name
    name          = aws_glue_catalog_table.ticket_logs.name
  }
}

# 2. Restricted, Column-Level Access for the Data Analyst User
resource "aws_lakeformation_permissions" "analyst_table_access" {
  principal   = aws_iam_user.data_analyst.arn
  permissions = ["SELECT"]

  table_with_columns {
    database_name = aws_glue_catalog_database.audit_db.name
    name          = aws_glue_catalog_table.ticket_logs.name

    # Explicitly list ONLY the safe columns the analyst is authorized to view
    column_names = ["ticket_id", "event_name", "price"]
  }
}
