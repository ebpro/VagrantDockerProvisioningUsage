# Docker Engine avec Vagrant et Ansible

Un exemple d'utilisation de Vagrant pour provisionner une VM et d'ansible pour installer Docker à l'intérieur pour permettre une utilisation de docker en simple utilisateur.

## Installer Vagrant

```bash
mkdir -p ~/bin && export PATH=~/bin:$PATH
wget -qO- https://releases.hashicorp.com/vagrant/2.3.3/vagrant_2.3.3_linux_amd64.zip|gunzip - > ~/bin
chmod +x ~/bin/vagrant
```

## Paramétrer VirtualBox pour le stockage

Si besoin, il est possible de stocker les images des VM dans un autre répertoire par défaut :

```bash
VBoxManage list systemproperties | grep "Default machine folder:" && \
    mkdir -p /scratch/${USER} && \
    vboxmanage setproperty machinefolder /scratch/${USER}
```

### Si besoin d'un proxy HTTP

Installer le plugin vagrant pour les proxy :

```bash
vagrant plugin install vagrant-proxyconf
```

Définir les adresses des proxy et URLEncoder si besoin le password dans les variables standards :

```bash
export http_proxy=http://<login>:<password>@proxy.univ-tln.fr:3128
export https_proxy=http://<login>:<password>@proxy.univ-tln.fr:3128
export no_proxy=127.0.0.1
```

puis définir celles utilisées par Vagrant pour régler la VM :

```bash
export VAGRANT_HTTP_PROXY=${http_proxy}
export VAGRANT_HTTPS_PROXY=${https_proxy}
export VAGRANT_NO_PROXY=${no_proxy}
```

### Utilisation d'une box préfabriquée

Cloner ce repository

Il est possible de configurer la VM (redirect de ports, montage de répertoires, ...) en éditant le fichier Vagrantfile. 

Lancer Vagrant depuis le répertoire créé.

```bash
vagrant up
```

Il est possible d'afficher l'adresse IP de cette VM :

```bash
vagrant ssh --command "ip -4 -oneline -color addr show"
```

et de s'y connecter avec ssh depuis le répertoire du projet.

```bash
vagrant ssh
```

Docker est disponible dans la VM.

### Utiliser docker depuis l'hôte

Pour utiliser Docker depuis l'hôte, il faut installer un client docker  sur l'hôte:

```bash
curl -sL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.19.tgz  | \
    tar --directory=/home/bruno/bin/ --strip-components=1 -zx docker/docker &&\
     chmod +x ~/bin/docker
```

Puis définir le point de connexion de Docker , enlever les clés publiques existantes et ajouter la nouvelle (dans des variable d'environement) :

```bash
. ./set-docker-env.sh
```

Il est alors possible d'utiliser les commandes docker depuis l'hôte et qu'elles s'éxecute dans la VM :

```bash
mkdir -p data/my-web-site
echo "Hello Docker" >   data/my-web-site/index.html
docker run --rm -p8080:80 -v ${PWD}/data/my-web-site::/usr/share/nginx/html nginx