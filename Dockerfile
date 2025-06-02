# ================================
# 1. Build Stage
# ================================
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copy only package files first to install dependencies
COPY package*.json ./

RUN npm install

# Copy the rest of the application source
COPY . .

# ================================
# 2. Production Stage
# ================================
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy only the compiled/built application and node_modules from builder
COPY --from=builder /usr/src/app /usr/src/app

ENV PORT=${PORT}

EXPOSE ${PORT}

CMD ["npm", "start"]

