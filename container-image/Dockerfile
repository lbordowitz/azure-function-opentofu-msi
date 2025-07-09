FROM mcr.microsoft.com/azure-functions/python:4-python3.11-appservice

# Install Azure CLI, OpenTofu and required tools
ADD install-tools.sh /tmp/install-tools.sh
RUN chmod +x /tmp/install-tools.sh && \
    /tmp/install-tools.sh

RUN mkdir -p /home/site/wwwroot/tf-demo

ADD requirements.txt   /home/site/wwwroot
ADD host.json          /home/site/wwwroot
ADD function_app.py    /home/site/wwwroot
ADD tf-demo/           /home/site/wwwroot/tf-demo

RUN pip install --upgrade pip && \
    pip install -r /home/site/wwwroot/requirements.txt

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true
