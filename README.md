# 🌦️ Node.js Weather App

A lightweight and responsive Node.js application that fetches real-time weather data using the OpenWeatherMap API. This app is containerized with Docker for easy local development and cloud deployment (e.g., AWS ECS, EC2, etc.).

---

## 🚀 Features

- Fetch current weather by city name  
- Displays temperature, humidity, and weather conditions  
- Dockerized for portability  
- Secure API key usage via `.env` or AWS Secrets Manager  
- Health check endpoint for monitoring and load balancer integration  

---

## 🧰 Prerequisites

Ensure the following tools are installed:

- [Git](https://git-scm.com/)  
- [Docker](https://www.docker.com/)  
- OpenWeatherMap API Key  

---

## 🛠️ Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/deeepak-tyagii/deployapp-gh-actions-aws.git
cd deployapp-gh-actions-aws
```

### 2. Create `.env` File

Create a `.env` file in the root directory with the following content:

```env
OPENWEATHER_API_KEY=your_openweather_api_key
PORT=3000
```

> 🔐 Replace `your_openweather_api_key` with your actual API key from OpenWeatherMap.

---

### 3. Build Docker Image

```bash
docker build -t weatherapp .
```

---

### 4. Run Docker Container

```bash
docker run -d -p 3000:3000 --env-file .env --name weatherapp-container weatherapp
```

---

## 🌐 Access the Application

Open your browser and visit:

```
http://localhost:3000
```

---

## 📡 API Endpoint

The application exposes the following API:

```
GET /api/weather?city=<city_name>
```

**Example:**

```
GET http://localhost:3000/api/weather?city=London
```

Returns current weather data including temperature, humidity, and conditions for the specified city.

---

## 🩺 Health Check

```bash
curl http://localhost:3000/health
```

Returns `200 OK` if the app is healthy.

---

## 🧼 Stopping & Cleaning Up

To stop and remove the container:

```bash
docker stop weatherapp-container
docker rm weatherapp-container
```

To remove the Docker image:

```bash
docker rmi weatherapp
```

---

## 🔐 Security

* API keys should **never** be hardcoded.
* `.env` is ignored by `.gitignore` to prevent accidental commits.
* For production use AWS Secrets Manager or SSM Parameter Store.

---
