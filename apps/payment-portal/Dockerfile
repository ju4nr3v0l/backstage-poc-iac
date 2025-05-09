# Usa una imagen base de Node.js oficial. Escoge una versión LTS (Long Term Support).
FROM node:23-alpine

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Copia los archivos package.json y package-lock.json (o yarn.lock)
# Usamos `../..` porque el package.json está en la raíz del monorepo
# y asumimos que contiene todas las dependencias necesarias.
COPY package.json package-lock.json* ./

# Instala TODAS las dependencias del proyecto listadas en el package.json raíz.
# Esto es más simple para empezar en un monorepo si no tienes configuraciones de workspaces complejas
# o si `payment-portal` depende de otros paquetes locales del monorepo.
# Si `payment-portal` tuviera su propio package.json, copiarías ese y ejecutarías npm install en él.
RUN npm install --production

# Copia el código fuente de la aplicación payment-portal al directorio de trabajo.
# Esto asume que el Dockerfile está en apps/payment-portal/
# y copia todo desde esa carpeta al WORKDIR del contenedor.
COPY . .

# Expone el puerto en el que la aplicación se ejecuta dentro del contenedor
EXPOSE 3000

# Comando para ejecutar la aplicación
# Asegúrate de que app.js está en la raíz del WORKDIR (que ahora es /usr/src/app)
CMD [ "node", "app.js" ]
