from airflow.contrib.operators.bigquery_operator import BigQueryOperator
from airflow.contrib.operators.gcs_to_bq import GoogleCloudStorageToBigQueryOperator
from airflow.contrib.operators.gcs_to_gcs import GoogleCloudStorageToGoogleCloudStorageOperator
from airflow.operators.dummy_operator import DummyOperator


def _create_merge_sql(source, target, schema, **context):
    columns = [item["name"] for item in schema]
    columns = ",".join(columns)
    return f"""
        MERGE `{target}` T
        USING `{source}` S
        ON T.cdc_hash = TO_BASE64(MD5(TO_JSON_STRING(S)))
        WHEN NOT MATCHED THEN
          INSERT ({columns}, inserted_at, cdc_hash)
          VALUES ({columns}, CURRENT_DATETIME(), TO_BASE64(MD5(TO_JSON_STRING(S))))
    """


def gc_tasks(name, schema, next_task=DummyOperator(task_id="Done")):
    bq_staging = "{{{{ var.value.gc_project_id }}}}.{{{{ var.value.bq_dataset_source }}}}.{0}".format(name)
    bq_warehouse = "{{{{ var.value.gc_project_id }}}}.{{{{ var.value.bq_dataset_target }}}}.{0}".format(name)

    t1 = GoogleCloudStorageToBigQueryOperator(
        task_id=f"staging_{name}",
        bucket="{{var.value.gcs_bucket}}",
        source_objects=[f"{name}*"],
        destination_project_dataset_table=bq_staging,
        write_disposition="WRITE_TRUNCATE",
        schema_fields=schema,
        skip_leading_rows=1,
    )

    t2 = BigQueryOperator(
        task_id=f"merge_{name}_into_warehouse",
        sql=_create_merge_sql(bq_staging, bq_warehouse, schema),
        use_legacy_sql=False,
    )

    t3 = GoogleCloudStorageToGoogleCloudStorageOperator(
        task_id=f"move_{name}_to_processed",
        source_bucket="{{var.value.gcs_bucket}}",
        source_object=f"{name}*",
        destination_bucket="{{var.value.gcs_bucket}}",
        destination_object=f"processed/{name}",
        move_object=True,
    )

    t1 >> t2 >> t3 >> next_task

    return t1
