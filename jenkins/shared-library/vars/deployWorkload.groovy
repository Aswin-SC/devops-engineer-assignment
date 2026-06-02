def call(String deployment, String container, String image, String namespace = 'devops-assignment') {
  sh "kubectl set image deployment/${deployment} ${container}=${image} -n ${namespace}"
  sh "kubectl rollout status deployment/${deployment} -n ${namespace} --timeout=180s"
}
