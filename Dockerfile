FROM rocker/geospatial:4.1
MAINTAINER Diego Valle-Jones

# From https://hub.docker.com/r/jrnold/rstan/dockerfile

#RUN apt-get clean
#RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.org'))" >> /usr/local/lib/R/etc/Rprofile.site


RUN apt-get update \
&& apt-get install -y --no-install-recommends apt-utils ed libnlopt-dev libgdal-dev libudunits2-dev cargo jags libcairo2-dev libxt-dev libgeos-dev \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/
  
# Install rstan
RUN install2.r --error --deps TRUE \
rstan \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Global site-wide config -- neeeded for building packages
RUN mkdir -p $HOME/.R/ \
&& echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs \n" >> $HOME/.R/Makevars

# Config for rstudio user
RUN mkdir -p $HOME/.R/ \
&& echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs -Wno-ignored-attributes -Wno-deprecated-declarations\n" >> $HOME/.R/Makevars \
&& echo "rstan::rstan_options(auto_write = TRUE)\n" >> /home/rstudio/.Rprofile \
&& echo "options(mc.cores = parallel::detectCores())\n" >> /home/rstudio/.Rprofile

# Install rstan
RUN install2.r --error --deps TRUE \
rstan \
loo \
bayesplot \
rstanarm \
rstantools \
shinystan \
ggmcmc \
tidybayes \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN install2.r --error --deps TRUE \
zoo  \
mgcv \
lubridate \
stringr  \
loo \
jsonlite \
scales \
directlabels \
betareg \
extrafont \
pointdensityP \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install Roboto condensed
RUN wget -O /tmp/rc.zip https://fonts.google.com/download?family=Roboto%20Condensed \
&& cd /usr/share/fonts \
&& sudo mkdir googlefonts \
&& cd googlefonts \
&& sudo unzip -d . /tmp/rc.zip \
&& sudo chmod -R --reference=/usr/share/fonts/truetype /usr/share/fonts/googlefonts \
&& sudo fc-cache -fv \
&& rm -rf /tmp/rc.zip \
&& Rscript --slave --no-save --no-restore-history -e "extrafont::font_import(prompt=FALSE)"


#
RUN apt-get update && apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash -
RUN apt-get -y install nodejs
RUN npm install    


RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y build-essential libssl-dev libffi-dev python3 python3-dev python3-pip && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash elcrimen

# Install Ansible
RUN apt-get -y update &&  \
    apt-get -y upgrade &&  \
    apt-get -q -y --no-install-recommends install python3-yaml \
               python3-jinja2 python3-httplib2 \
               python3-paramiko python3-setuptools \
               python3-pkg-resources git python3-pip &&  \
    mkdir -p /etc/ansible/ &&  \
    pip install ansible==4.7 
    
    
# Install required packages
RUN apt-get -y update &&  \  
    apt-get -q -y --no-install-recommends install git \
        curl \
        libreoffice \
        libcurl4-openssl-dev \
        sqlite3 \
        imagemagick \
        optipng \
        htop \
        apt-transport-https \
        openssh-client \
        rsync \
        nano \
        inkscape \
        wget \
        curl \
        unzip \
        nasm \
        gcc \
        build-essential \
        inkscape && \
        rm -rf /var/lib/apt/lists/*
        
    
WORKDIR /etc/ansible
# Add ansible configuration
ADD ansible/ /etc/ansible
RUN ansible-playbook -c local /etc/ansible/playbook.yml && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    

# Add R packages
RUN Rscript --slave --no-save --no-restore-history /home/rstudio/new.crimenmexico/R/src/load-packages.R && \
 	rm -rf /tmp/downloaded_packages/ /tmp/*.rds && \
 	rm -rf /var/lib/apt/lists/*
# Add fonts to R
RUN find /home/rstudio/new.crimenmexico/R/fonts/ -type f -name '*.ttf' -print -exec cp {} /usr/share/fonts/truetype/ \;
RUN Rscript --slave --no-save --no-restore-history -e "extrafont::font_import(prompt=FALSE)"
# Add GitHub R packages
RUN Rscript --slave --no-save --no-restore-history -e "devtools::install_github('diegovalle/mxmortalitydb')" && \
    Rscript --slave --no-save --no-restore-history -e "devtools::install_github('twitter/AnomalyDetection')" && \
    Rscript --slave --no-save --no-restore-history -e "devtools::install_github('diegovalle/mxmaps')" &&  \
 	rm -rf /tmp/downloaded_packages/ /tmp/*.rds && \
 	rm -rf /var/lib/apt/lists/* 

#RUN chown -R rstudio:rstudio /usr/local/lib/R/site-library

RUN npm install --unsafe-perm=true -g npm@6.14.5 && npm install --unsafe-perm=true -g gatsby-cli@2.11.5
RUN npm install -g --unsafe-perm=true netlify-cli@4.1.18

RUN usermod -a -G staff rstudio
# Build a statically linked version of V8 to avoid library not found errors
RUN Rscript --slave --no-save \
 --no-restore-history \
 -e "Sys.setenv(DOWNLOAD_STATIC_LIBV8 = 1);install.packages('https://mran.revolutionanalytics.com/snapshot/2021-10-20/src/contrib/V8_3.4.2.tar.gz',  type='source')" &&  \
 	rm -rf /tmp/downloaded_packages/ /tmp/*.rds && \
 	rm -rf /var/lib/apt/lists/* 

USER rstudio
WORKDIR /home/rstudio/new.crimenmexico/elcri.men
RUN npm install && gatsby telemetry --disable
COPY src/data /home/rstudio/new.crimenmexico/elcri.men/src/data
RUN gatsby build --verbose

WORKDIR /home/rstudio/new.crimenmexico

ENTRYPOINT ["/bin/bash"]
