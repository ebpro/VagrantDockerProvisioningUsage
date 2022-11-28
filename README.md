# Docker Engine avec Vagrant et Ansible

Un exemple d'utilisation de Vagrant pour provisionner une VM et d'ansible pour installer Docker à l'intérieur pour permettre une utilisation de docker en simple utilisateur.

## Installer Vagrant

```bash
mkdir -p ~/bin && \
    export PATH=~/bin:$PATH && \
    wget -qO- https://releases.hashicorp.com/vagrant/2.3.3/vagrant_2.3.3_linux_amd64.zip|gunzip - \
    > ~/bin/vagrant && \
    chmod +x ~/bin/vagrant
```

## Paramétrer VirtualBox pour le stockage

Si besoin, il est possible de stocker les images des VM dans un autre répertoire par défaut :

```bash
VBoxManage list systemproperties | grep "Default machine folder:" && \
    mkdir -p /scratch/${USER} && \
    vboxmanage setproperty machinefolder /scratch/${USER}/VirtualBox\ VMs && \
    echo -n "New " && VBoxManage list systemproperties | grep "Default machine folder:" 
```

### Si besoin d'un proxy HTTP

Installer le plugin vagrant pour les proxy :

```bash
vagrant plugin install vagrant-proxyconf
```

Définir les adresses des proxies et URLEncoder si besoin le password dans les variables standards :

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

Dans l'hôte ajouter le fichier `~/.docker/config.json` pour le variable du proxy soient fixée dans chaque container dans la VM.

```json
{
  "proxies": {
    "default": {
      "httpProxy": "http://username:password@proxy.univ-tln.fr:3128",
      "httpsProxy": "http://username:password@proxy.univ-tln.fr:3128",
      "noProxy": "127.0.0.1"
    }
  }
}
```

> **_NOTE:_**  ATTENTION wget fourni dans busybox en semble pas suporter le CONNECT de HTTP, il faut donc installer explicitement wget dans vos container.

### Utilisation d'une box préfabriquée

Pour démarrer un VM contenant docker :
  
   1. Cloner ce repository
   2. Editer si besoin le fichier `Vagrantfile` pour configurer la VM (redirection de ports de l'hôte vers la VM, montage de répertoires de l'hôtes vers la VM, ...).
   3. Lancer Vagrant depuis le répertoire créé.

        ```bash
            vagrant up
        ```

Une fois la VM lancée, il est possible d'afficher l'adresse IP de cette VM :

```bash
vagrant ssh --command "ip -4 -oneline -color addr show"
```

et de s'y connecter avec ssh depuis le répertoire du projet :

```bash
vagrant ssh
```

Docker est disponible dans la VM.

### Utiliser docker depuis l'hôte

Pour utiliser Docker depuis l'hôte, il faut installer un client docker  sur l'hôte:

```bash
curl -sL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.19.tgz  | \
    tar --directory=${HOME}/bin/ --strip-components=1 -zx docker/docker &&\
     chmod +x ~/bin/docker  

mkdir -p ${HOME}/.docker/cli-plugins/ && 
  curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o ${HOME}/.docker/cli-plugins/docker-compose && \
  chmod +x  ${HOME}/.docker/cli-plugins/docker-compose
```

Puis définir le point de connexion de Docker, enlever les clés publiques existantes et ajouter la nouvelle (dans des variables d'environement). Le script suivant fait tout cela.

```bash
. ./set-docker-env.sh
```

En ajoutant la fonction suivante dans le .bashrc ou le .zshrc, la connexions vers le docker engine sera faite dans chaque shell en invoquant `use-vagrant-docker`.

```bash
use-vagrant-docker () ( VAGRANT_dockerNode1Path=`vagrant global-status | \
    grep docker-node-1|\
    grep "running"| \
    cut -f 6 -d ' ' ` && \
    [[ -f "$VAGRANT_dockerNode1Path/set-docker-env.sh" ]] && \
        cd  ${VAGRANT_dockerNode1Path}\
        && . ./set-docker-env.sh \
        && cd ~
)        
```

### Exemple d'utilisation

Il est alors possible d'utiliser les commandes docker depuis l'hôte et qu'elles s'éxecutent dans la VM :

```bash
mkdir -p data/my-web-site
echo "Hello Docker" >   data/my-web-site/index.html
docker run \
    --rm -\
    p 8080:80 \
    -v /vagrant/data/my-web-site:/usr/share/nginx/html nginx
```

L'exemple suivant exécute le serveur Web Nginx dans un container de la VM. Le port 80 du container est associé au port 8080 de la VM, qui est à son tour associé au port de l'hôte (a priori 8080 aussi cf. Vagrantfile). Le répertoire courant du projet est monté dans le répertoire `/vagrant` de la VM. Donc le sous-répertoire `data/my-web` du projet est donc monté la VM puis dans le répertoire `/usr/share/nginx/html` du conteneur.

Le site web du répertoire du l'hôte `data/my-web` est donc accessible depuis l'hôte à l'adresse `http://localhost:8080` via un serveur nginx exécuté dans un conteneur de la VM.
