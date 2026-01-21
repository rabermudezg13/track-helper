FROM node:18-alpine

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install --only=production

# Copiar el resto de la aplicación
COPY . .

# Crear directorio para uploads
RUN mkdir -p uploads public


# Exponer puertos
EXPOSE 3030 3031

# Iniciar la aplicación
CMD ["node", "server.js"]
