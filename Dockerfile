FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    wget curl unzip gnupg xvfb libnss3 libatk-bridge2.0-0 libgtk-3-0 \
    libxss1 libasound2 libgbm-dev libxshmfence1 libxcomposite1 \
    fonts-liberation libappindicator3-1 xdg-utils \
    python3-tk python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip list
COPY . .

CMD [ "python3" , "./src/main.py" ]