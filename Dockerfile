FROM 043028989942.dkr.ecr.us-gov-west-1.amazonaws.com/sagemaker-default-image:latest

# Set environment variables for Chrome
ENV CHROME_BIN=/usr/bin/google-chrome-stable \
    CHROMEDRIVER_PATH=/usr/local/bin/chromedriver

RUN apt-get install -y wget
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get -y install google-chrome-stable

WORKDIR /project

RUN apt-get -y install dos2unix
RUN apt -y install xvfb

ADD ./requirements.txt /tmp/requirements.txt

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

ADD . .

# Make main.py file(s) executable
RUN chmod +x ./main.py

# Run Dos2Unix for all main Python script(s)
RUN dos2unix ./main.py

RUN mkdir /static
