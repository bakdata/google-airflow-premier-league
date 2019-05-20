import json
from datetime import datetime, timedelta

from airflow import DAG
from airflow.contrib.sensors.gcs_sensor import GoogleCloudStoragePrefixSensor
from airflow.operators.dagrun_operator import TriggerDagRunOperator

from util.gc_tasks import gc_tasks


def create_dag(dag_id, default_args):
    dag = DAG(dag_id=dag_id, schedule_interval=None, default_args=default_args)

    with dag:
        wait_for_data = GoogleCloudStoragePrefixSensor(
            task_id=f"wait_for_{key}_data",
            bucket="{{ var.value.gcs_bucket }}",
            prefix=key,
        )

        rerun_dag = TriggerDagRunOperator(
            task_id=f"rerun_{key}_dag",
            trigger_dag_id=dag.dag_id,
        )

        wait_for_data >> gc_tasks(key, values.get("schema"), rerun_dag)

    return dag


description = open('./dags/description.json', 'r').read()
for key, values in json.loads(description).items():
    default_args = {
        "owner": "bakdata",
        "start_date": datetime(2019, 1, 1),
        "email": [],
        "email_on_failure": False,
        "email_on_retry": False,
        "retries": 0,
        "retry_delay": timedelta(minutes=5),
    }

    dag_id = f"{key}_data_gc"

    globals()[dag_id] = create_dag(dag_id, default_args)
