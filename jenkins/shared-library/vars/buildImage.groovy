def call(String name, String context, String tag) {
  sh "docker build -t ${name}:${tag} ${context}"
}
