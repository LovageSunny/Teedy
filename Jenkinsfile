pipeline {
  agent any

  environment {
    DOCKER_NAMESPACE = 'lovagesunny'
    DOCKER_REPOSITORY = 'teedy'
    DOCKER_TAG = 'v1.0'
  }

  stages {
    stage('Building image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
          script {
            runCommand(
              'DOCKER_BUILDKIT=1 docker build --pull=false -t "$DOCKER_NAMESPACE/$DOCKER_REPOSITORY:$BUILD_NUMBER" -t "$DOCKER_NAMESPACE/$DOCKER_REPOSITORY:$DOCKER_TAG" .',
              'set "DOCKER_BUILDKIT=1" && docker build --pull=false -t "%DOCKER_NAMESPACE%/%DOCKER_REPOSITORY%:%BUILD_NUMBER%" -t "%DOCKER_NAMESPACE%/%DOCKER_REPOSITORY%:%DOCKER_TAG%" .'
            )
          }
        }
      }
    }

    stage('Upload Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
          script {
            runCommand(
              '''
                set -eu
                DOCKER_IMAGE="$DOCKER_NAMESPACE/$DOCKER_REPOSITORY:$DOCKER_TAG"
                echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                docker push "$DOCKER_IMAGE"
              ''',
              '''
                @echo off
                set "DOCKER_IMAGE=%DOCKER_NAMESPACE%/%DOCKER_REPOSITORY%:%DOCKER_TAG%"
                echo %DOCKERHUB_PASSWORD% | docker login -u "%DOCKERHUB_USERNAME%" --password-stdin
                docker push "%DOCKER_IMAGE%"
              '''
            )
          }
        }
      }
    }

    stage('Run containers') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
          script {
            runCommand(
              '''
                set -eu
                DOCKER_IMAGE="$DOCKER_NAMESPACE/$DOCKER_REPOSITORY:$DOCKER_TAG"

                docker pull "$DOCKER_IMAGE"
                docker rm -f teedy-8082 teedy-8083 teedy-8084 2>/dev/null || true

                docker run -d --name teedy-8082 -p 8082:8080 "$DOCKER_IMAGE"
                docker run -d --name teedy-8083 -p 8083:8080 "$DOCKER_IMAGE"
                docker run -d --name teedy-8084 -p 8084:8080 "$DOCKER_IMAGE"

                docker ps --filter "name=teedy-" --format "table {{.Names}}\\t{{.Image}}\\t{{.Ports}}\\t{{.Status}}"
              ''',
              '''
                @echo off
                set "DOCKER_IMAGE=%DOCKER_NAMESPACE%/%DOCKER_REPOSITORY%:%DOCKER_TAG%"

                docker pull "%DOCKER_IMAGE%"
                docker rm -f teedy-8082 teedy-8083 teedy-8084 2>NUL || ver >NUL

                docker run -d --name teedy-8082 -p 8082:8080 "%DOCKER_IMAGE%"
                docker run -d --name teedy-8083 -p 8083:8080 "%DOCKER_IMAGE%"
                docker run -d --name teedy-8084 -p 8084:8080 "%DOCKER_IMAGE%"

                docker ps --filter "name=teedy-" --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
              '''
            )
          }
        }
      }
    }
  }
}

void runCommand(String unixCommand, String windowsCommand = null) {
  if (isUnix()) {
    sh unixCommand
  } else {
    bat(windowsCommand ?: unixCommand)
  }
}
