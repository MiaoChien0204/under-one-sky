FROM rocker/shiny:4.0.2

RUN apt-get update 
RUN apt-get install -y apt-transport-https
RUN apt-get install -y libgdal-dev libproj-dev libgeos-dev libcurl4-openssl-dev libudunits2-dev libpq-dev zlib1g-dev libsasl2-dev libssh2-1-dev libv8-dev libssl-dev
RUN mkdir -p /var/lib/shiny-server/bookmarks/shiny
  
# Download and install library
RUN R -e "install.packages(c('Rcpp','BH','base64enc','magrittr','httpuv','mime','jsonlite', 'httr'))"
RUN R -e "install.packages(c('sys', 'askpass', 'curl','openssl', 'usethis'))"
RUN R -e "install.packages(c('xtable','digest','htmltools','R6','sourcetools','later','promises'))"
RUN R -e "install.packages(c('crayon','rlang','fastmap','withr','commonmark','glue','assertthat'))"
RUN R -e "install.packages(c('utf8','cli','fansi','pillar','pkgconfig','purrr','ellipsis','generics'))"
RUN R -e "install.packages(c('lifecycle','tibble','tidyselect','vctrs','backports','prettyunits','rprojroot', 'units'))"
RUN R -e "install.packages(c('pkgbuild','rstudioapi','diffobj','rematch2','brio','callr','desc','evaluate','pkgload'))"
RUN R -e "install.packages(c('praise','processx','ps','waldo','testthat','colorspace','gtable','isoband'))"
RUN R -e "install.packages(c('lazyeval','yaml','xfun','farver','labeling','munsell','viridisLite','ggplot2','gridExtra'))"
RUN R -e "install.packages(c('crosstalk','htmlwidgets','markdown','png','RColorBrewer','raster','scales','sp','viridis','leaflet.providers','shiny'))"
RUN R -e "install.packages(c('dplyr', 'leaflet', 'lubridate', 'shinyWidgets', 'DT'))"
RUN R -e "install.packages(c('plotly', 'sf', 'mongolite', 'shinydashboard', 'shinycssloaders','shinythemes', 'devtools'))"
RUN R -e "install.packages('rgdal', repos = 'http://cran.us.r-project.org', type = 'source')"
RUN R -e "devtools::install_github('rstudio/leaflet', ref='joe/feature/raster-options')"




# # copy the app to the image 
# COPY APU-dashboard /srv/shiny-server/

# # allow permission
# RUN sudo chown -R shiny:shiny /srv/shiny-server

# EXPOSE 3838

# RUN chmod -R 755 /usr/bin

# COPY shiny-server.sh /usr/bin/shiny-server.sh

# RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

# # run app
# CMD ["/usr/bin/shiny-server.sh"]


# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY APU-dashboard /srv/shiny-server/APU-dashboard

RUN sudo chown -R shiny:shiny /srv/shiny-server
RUN sudo rm -r -f /srv/shiny-server/01_hello/ /srv/shiny-server/02_text/ /srv/shiny-server/03_reactivity/ /srv/shiny-server/04_mpg/ /srv/shiny-server/05_sliders/ /srv/shiny-server/06_tabsets/ /srv/shiny-server/07_widgets/ /srv/shiny-server/08_html/ /srv/shiny-server/09_upload/ /srv/shiny-server/10_download/ /srv/shiny-server/11_timer/ /srv/shiny-server/sample-apps

RUN rm /srv/shiny-server/index.html
COPY index.html /srv/shiny-server/index.html



# Make the ShinyApp available at port 80
EXPOSE 80

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]
CMD ["/usr/bin/shiny-server.sh"]

