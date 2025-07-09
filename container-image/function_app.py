import azure.functions as func
import datetime
import json
import logging

import subprocess

app = func.FunctionApp()


@app.function_name(name="timer")
@app.timer_trigger(schedule="0 */1 * * * *", 
              arg_name="timer",
              run_on_startup=False) 
def test_function(timer: func.TimerRequest) -> None:
    utc_timestamp = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
    logging.info('Python function triggered at %s', utc_timestamp)
    command = ["/bin/bash", "-c", "/home/site/wwwroot/tf-demo/deploy.sh"]
    logging.info('Invoking command: %s', command)
    proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = proc.stdout.read()
    logging.info('Output: %s', output.decode())