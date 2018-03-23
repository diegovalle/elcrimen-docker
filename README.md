# elcrimen-docker

Dockerfile to create the docker image to create the website for https://elcri.men

Note: the Dockerfile is for performing the data analysis and not for hosting the website

There is an ansible script in the ansible directory for setting up an
Ubuntu 14.04 64 bit instance. You'll need one with at least 32GB of RAM (maybe more?). 
Run the following command to set up the server:

```sh
ansible-playbook -i hosts playbook.yml --vault-password-file=password.txt --extra-vars "secrets=true"
```

The ansible script depends on a secrets.yml file whose structure is:

```
ssh_key: |
  -----BEGIN RSA PRIVATE KEY-----
  ...
  -----END RSA PRIVATE KEY-----
key_file: /root/.ssh/crimenmexico
```

The ssh key is needed to copy the website to the staging server.

Once the instance is
setup you can run the build.sh script in the new.crimenmexico
directory. If everything went OK the website should be in the
crimenmexico.diegovalle.net directory.
