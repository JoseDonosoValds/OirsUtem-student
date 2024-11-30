# Aplicación móvil flutter de Gestión de Solicitudes para la asignatura Computación Móvil de la Universidad Tecnológica Metropolitana.

## COMPUTACION MOVIL

Docente: Sebastian Salazar Molina.

Seccion: 301 - EFE68500.

Fecha: 30/11/2024.

**Descripción**:  
La aplicación desarrollada en flutter para la Oficina de Información, Reclamos y Sugerencias - OIRS, que permite a los usuarios (estudiantes de la Universidad Tecnológica Metropolitana - UTEM) gestionar sus solicitudes llamadas **Tickets** de manera eficiente. A través de la interfaz de usuario, los usuarios pueden crear solicitudes, ver el estado de las solicitudes anteriores, y actualizar o eliminar solicitudes. Además, la aplicación soporta la autenticación a través de Google y se comunica con una API para manejar los datos de las solicitudes.

## Índice

1. [Descripción](#descripción)
2. [Características](#características)
3. [Instalación](#instalación)
4. [Uso](#uso)
5. [Contribuidores](#contribuidores)
6. [Estructura del Proyecto](#estructura-del-proyecto)

## Descripción

Esta aplicación está diseñada para gestionar solicitudes en una plataforma centralizada. Los usuarios pueden:
- **Iniciar sesión con Google** para autenticarse.
- **Crear solicitudes** de tipo "Reclamo", "Sugerencia" o "Información".
- **Ver el estado** de sus solicitudes anteriores.
- **Actualizar solicitudes** y adjuntar archivos a las mismas.
- **Filtrar solicitudes** por categorías.

## Características

- **Autenticación con Google**: Los usuarios pueden iniciar sesión usando sus cuentas de Google.
- **Gestión de solicitudes**: Los usuarios pueden crear, ver, actualizar y filtrar solicitudes.
- **Interfaz intuitiva**: Navegación sencilla entre las vistas de "Mis Solicitudes" y "Crear Solicitudes".
- **Adjuntar archivos**: Los usuarios pueden adjuntar archivos a sus solicitudes.
- **Interacción con una API**: La aplicación realiza solicitudes a un servidor para obtener, enviar y actualizar datos.

## Instalación

### Prerequisitos

Asegúrate de tener instalado lo siguiente:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) o [Visual Studio Code](https://code.visualstudio.com/)
- Una cuenta de **Google** para la autenticación.

### Pasos para la instalación

1. Clona el repositorio en tu máquina local:

   ```bash
   git clone https://github.com/JoseDonosoValds/flutter-app.git
2. Navega al directorio del proyecto:
   ```bash
   cd flutter-app

3. Instala las dependencias:
   ```bash
   flutter pub get
## Ejecución
1. Conecta un dispositivo o inicia un emulador.
2. Ejecuta el proyecto:
   ```bash
   flutter run
## Uso

### Iniciar sesión

1. Abre la aplicación y selecciona "Iniciar sesión con Google".
2. Ingresa con tu cuenta de Google.

### Crear una solicitud

1. Presiona alguno de los 3 botones (amarillo para reclamo, verde para sugerencia o azul para información) o ve a "Mis Solicitudes" presionando "Solicitudes" en la barra inferior y presiona el botón con el signo +.
2. Elige la categoría
3. Selecciona el tipo de solicitud.
4. Escribe un asunto y mensaje.
5. Opcionalmente, adjunta un archivo.
6. Haz clic en "Enviar Solicitud".

### Ver mis solicitudes

1. Ve a la pantalla "Mis Solicitudes" presionando "Solicitudes" en la barra inferior para ver todas tus solicitudes previas.
2. Puedes aplicar filtros por categoría para organizar las solicitudes.
3. Toca una solicitud para ver sus detalles, actualizarla o adjuntar más archivos.

## Contribuidores
- **Dylan Díaz**
- **Diego Aguirre**
- **José Donoso**

## Estructura del Proyecto

- **Pantallas**:
  - **LoginScreen**: Vista para iniciar sesión usando Google.
  - **HomeScreen**: Vista principal, donde los usuarios pueden crear solicitudes rápidamente.
  - **CrearSolicitudScreen**: Vista para crear una nueva solicitud, donde el usuario puede elegir tipo, asunto, mensaje y adjuntar archivos.
  - **MisSolicitudesScreen**: Vista donde el usuario puede ver, filtrar y actualizar las solicitudes previamente enviadas.
    
- **Servicios**:
  - **GoogleServices**: Maneja la autenticación con Google y Firebase.
  - **ApiService**: Realiza las peticiones a la API para manejar las solicitudes y sus datos.

