FROM nginx:alpine

# Copy the API tester files
COPY index.html /usr/share/nginx/html/

# Configure nginx to serve on port 8899
RUN echo 'server { \
    listen 8899; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8899

CMD ["nginx", "-g", "daemon off;"]
