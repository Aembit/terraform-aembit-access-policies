FROM public.ecr.aws/lambda/python:3.12

# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install -r requirements.txt

# Copy function code
COPY handler.py ${LAMBDA_TASK_ROOT}

COPY --from=aembit/aembit_aws_lambda_extension:latest /extension/ /opt/extensions

COPY aembit_root.crt "/etc/pki/ca-trust/source/anchors"
RUN update-ca-trust

CMD [ "handler.lambda_handler" ]
