FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-venv python3-pip && \
    apt-get install -y libgl1 && \
    rm -rf /var/lib/apt/lists/*

RUN python3.10 -m venv /app/venv

WORKDIR /app

COPY . .

RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV FLASK_APP=app.py

CMD ["/app/venv/bin/python", "-m", "flask", "run", "--host=0.0.0.0"]