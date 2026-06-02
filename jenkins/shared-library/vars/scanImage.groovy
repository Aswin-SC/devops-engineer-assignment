def call(String image) {
  sh "trivy image --severity CRITICAL --exit-code 1 ${image}"
}
