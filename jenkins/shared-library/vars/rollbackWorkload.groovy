def call(String deployment, String namespace = 'devops-assignment') {
  sh "kubectl rollout undo deployment/${deployment} -n ${namespace}"
}
