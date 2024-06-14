# Automatización de Pipeline de CI/CD para Microservicio y API Proxy


## Axel Casas Espinosa

---

### Evaluación DevOps

#### Requerimiento Funcional

La dirección Digital de Liverpool requiere una nueva funcionalidad en la página de ecommerce para ofrecer entregas en 24 horas a ciertos productos marcados desde la catalogación de estos.

#### Solución Técnica

Para dar atención al requerimiento, el equipo de ingeniería de software determinó el desarrollo de un microservicio en Java Spring Boot que, a su vez, será expuesto a través de una API proxy en Apigee y será consumida desde el backend del ecommerce.

El equipo de arquitectura e infraestructura determinó que el microservicio en Spring Boot debe estar desplegado en Cloud Run dentro de un proyecto llamado `liverpool-cloud-back`.

Para “APIficar” el microservicio, se creará un API proxy en Apigee que se encuentra en el proyecto `liverpool-cloud-api`.

#### DevOps

El equipo de ingeniería de software requiere la creación de un pipeline que considere lo siguiente:

- El código será versionado en un repositorio por cada artefacto.
- Pruebas unitarias y mocks para el microservicio.
- Validación de calidad de código.
- Despliegue en cada uno de los servicios de GCP en su respectivo proyecto.

Con la información proporcionada, desarrolla una propuesta de pipeline para el despliegue de los dos componentes a desarrollar por parte del equipo de ingeniería de software: el microservicio y la API proxy. Explica paso a paso de acuerdo al ciclo de CI/CD.

Bonus extra: Agrega scripts o pantallas de configuración para el paso correspondiente en las herramientas que consideres.

---

### Propuestas de Pipeline de CI/CD

#### 1. **Configuración del Repositorio**

- **Repositorio de Código:** Cada artefacto (microservicio y API proxy) tendrá su propio repositorio en Git.
- **Branch Strategy:** Utilización de ramas `main`, `develop` y `feature` para gestionar el desarrollo.

#### 2. **Integración Continua (CI)**

##### 2.1 **Desencadenador de CI**

- **Desencadenador:** Cada commit en ramas `main` o `develop` activará el pipeline.

##### 2.2 **Pruebas Unitarias y Mocks**

- **Herramientas:** JUnit para pruebas unitarias y Mockito para mocks.
- **Paso de Pipeline:** Ejecutar las pruebas unitarias para asegurar que el código no introduzca errores.

```yaml
steps:
  - name: 'Run unit tests'
    run: 'mvn test'
```

##### 2.3 **Validación de Calidad de Código**

- **Herramientas:** SonarQube para análisis de código estático.
- **Paso de Pipeline:** Análisis del código para verificar la calidad y adherencia a los estándares.

```yaml
steps:
  - name: 'Run SonarQube analysis'
    uses: SonarSource/sonarcloud-github-action@master
    with:
      projectKey: 'your_project_key'
      organization: 'your_organization'
```

#### 3. **Despliegue Continuo (CD)**

##### 3.1 **Construcción del Artefacto**

- **Herramientas:** Maven para construir el microservicio.
- **Paso de Pipeline:** Compilar y empaquetar el microservicio en un contenedor Docker.

```yaml
steps:
  - name: 'Build Docker image'
    run: |
      docker build -t gcr.io/$PROJECT_ID/microservicio:latest .
      docker push gcr.io/$PROJECT_ID/microservicio:latest
```

##### 3.2 **Despliegue en Cloud Run**

- **Herramientas:** Google Cloud SDK para despliegue en Cloud Run.
- **Paso de Pipeline:** Desplegar el microservicio en Cloud Run.

```yaml
steps:
  - name: 'Deploy to Cloud Run'
    run: |
      gcloud run deploy microservicio --image gcr.io/$PROJECT_ID/microservicio:latest --platform managed --region us-central1 --allow-unauthenticated
```

##### 3.3 **Despliegue de la API Proxy en Apigee**

- **Herramientas:** Apigee Management API.
- **Paso de Pipeline:** Crear y desplegar el proxy API en Apigee.

```yaml
steps:
  - name: 'Deploy API proxy'
    run: |
      apigeetool deployproxy -u $APIGEE_USER -p $APIGEE_PASSWORD -o $APIGEE_ORG -e $APIGEE_ENV -n microservicio-proxy -d ./apiproxy
```

#### 4. **Monitoreo y Notificaciones**

- **Herramientas:** Stackdriver para monitoreo, Slack para notificaciones.
- **Paso de Pipeline:** Monitorear el despliegue y enviar notificaciones.

```yaml
steps:
  - name: 'Notify Slack'
    uses: slackapi/slack-github-action@v1.13.2
    with:
      payload: '{"text":"Deployment completed successfully!"}'
```

### Script de Ejemplo para Pipeline en GitHub Actions

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main
      - develop

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up JDK 11
      uses: actions/setup-java@v2
      with:
        java-version: '11'

    - name: Build with Maven
      run: mvn package

    - name: Run unit tests
      run: mvn test

    - name: Run SonarQube analysis
      uses: SonarSource/sonarcloud-github-action@master
      with:
        projectKey: 'your_project_key'
        organization: 'your_organization'

    - name: Build Docker image
      run: |
        docker build -t gcr.io/$PROJECT_ID/microservicio:latest .
        docker push gcr.io/$PROJECT_ID/microservicio:latest

    - name: Deploy to Cloud Run
      run: |
        gcloud run deploy microservicio --image gcr.io/$PROJECT_ID/microservicio:latest --platform managed --region us-central1 --allow-unauthenticated

    - name: Deploy API proxy
      run: |
        apigeetool deployproxy -u $APIGEE_USER -p $APIGEE_PASSWORD -o $APIGEE_ORG -e $APIGEE_ENV -n microservicio-proxy -d ./apiproxy

    - name: Notify Slack
      uses: slackapi/slack-github-action@v1.13.2
      with:
        payload: '{"text":"Deployment completed successfully!"}'
```
