# CI/CD demo

Test locally (no Jenkins):
    docker build -t cicd-demo . && docker run -d -p 8081:80 --name cicd-demo cicd-demo

Jenkins prerequisites on the Linux server:
    sudo usermod -aG docker jenkins && sudo systemctl restart jenkins
