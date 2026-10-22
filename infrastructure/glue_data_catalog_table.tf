resource "aws_glue_catalog_table" "ticket_logs" {
  name          = "ticket_logs"
  database_name = aws_glue_catalog_database.audit_db.name
  catalog_id    = data.aws_caller_identity.current.account_id
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"         = "csv"
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.secure_audit_data_lake.bucket}/raw-logs/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "csv_serde"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        "separatorChar" = ","
        "quoteChar"     = "\""
      }
    }

    # Explicit schema definition representing sensitive audit logs
    columns {
      name = "ticket_id"
      type = "string"
    }
    columns {
      name = "customer_name" # Target for column-level data restriction
      type = "string"
    }
    columns {
      name = "credit_card_hash" # Target for column-level data restriction
      type = "string"
    }
    columns {
      name = "event_name"
      type = "string"
    }
    columns {
      name = "price"
      type = "double"
    }
  }
}
