FROM nginx:alpine
COPY ./html_css /usr/share/nginx/html
EXPOSE 80
