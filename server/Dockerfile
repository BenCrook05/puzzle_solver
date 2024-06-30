FROM ubuntu

RUN apt update 
RUN apt install python3.11-pip -y
RUN apt install python3.11-venv -y
RUN python3 -m venv /app/venv

WORKDIR /app

COPY . .

RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV FLASK_APP=app.py

CMD ["/app/venv/bin/python", "-m", "flask", "run", "--host=0.0.0.0"]