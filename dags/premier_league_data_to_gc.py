import json
from datetime import datetime, timedelta

from airflow import DAG
from airflow.contrib.sensors.gcs_sensor import GoogleCloudStoragePrefixSensor
from airflow.models import Variable
from airflow.operators.dagrun_operator import TriggerDagRunOperator

from util.gc_tasks import gc_tasks


def create_dag(dag_id, entity, schema, default_args):
    dag = DAG(dag_id=dag_id, schedule_interval=None, default_args=default_args)

    with dag:
        wait_for_data = GoogleCloudStoragePrefixSensor(
            task_id=f"wait_for_{entity}_data",
            bucket="{{ var.value.gcs_bucket }}",
            prefix=entity,
        )

        rerun_dag = TriggerDagRunOperator(
            task_id=f"rerun_{entity}_dag",
            trigger_dag_id=dag.dag_id,
        )

        wait_for_data >> gc_tasks(entity, schema, rerun_dag)

    return dag


airflow_home = Variable.get("airflow_home")
description = open(f'{airflow_home}/dags/description.json', 'r').read()
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

    dag_id = f"{key}_data_to_gc"

    globals()[dag_id] = create_dag(dag_id, key, values.get("schema"), default_args)
