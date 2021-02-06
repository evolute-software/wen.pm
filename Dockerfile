FROM node:14.15.4 as build

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz \
    && gunzip elm.gz \
    && chmod +x elm \
    && mv elm /usr/local/bin/ \
    && elm --help

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# install and cache app dependencies
COPY package.json /usr/src/app/package.json
RUN rm -rf /root/.node-gyp

# add app
COPY . /usr/src/app
RUN npm install 
RUN npm rebuild node-sass
RUN npm run package

#production stage
FROM httpd:2.4-alpine

ENV BACKEND_URL=https://backend.wen.pm

COPY --from=build /usr/src/app/dist /usr/local/apache2/htdocs

COPY devops /usr/local/apache2/devops
# Note: the assets folder is currently not bein included in the images

RUN ls -l /usr/local/apache2
RUN echo "Include devops/*.conf" >> /usr/local/apache2/conf/httpd.conf

ENTRYPOINT ["/usr/local/apache2/devops/configure.sh"]
CMD ["httpd-foreground"]

