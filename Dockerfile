# Use official lightweight Nginx image
FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy our HTML app into nginx's serving directory
COPY app/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80
