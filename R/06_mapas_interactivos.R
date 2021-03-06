# cargamos paquetes
pacman::p_load(tmap, sf, tidyverse, mapview, RColorBrewer, viridis,
               leafpop, leaflet, leaflet.extras, mapdeck, plotly, ggmap,
               ggiraph, widgetframe)

# cargamos archivo shp con poligonos de bavaria
bavaria <- read_sf("data/bavaria.shp")

# exploramos la densidad poblacional
bavaria$D__B_20

# creamos una paleta que nos va a servir para los colores
pal <- magma(n = length(unique(bavaria$D__B_20)), direction = -1)

# primera libreria que probaremos es tmap

tmap_mode("plot")
tm_shape(bavaria) + 
  tm_polygons(col = "D__B_20", palette = pal)

# tmap permite hacer graficos estaticos e interactivos

# para interactivos cambiamos el modo de visualizacion a "view"
tmap_mode("view")

# repetimos el mismo plot
tm_shape(bavaria) + 
  tm_polygons(col = "D__B_20", palette = pal)

# cambiamos el mapa base
tm_shape(bavaria) +
  tm_polygons(col = "D__B_20", palette = pal) +
  tm_basemap("Stamen.Watercolor")

# hacemos facetas del mapa segun distrito o ciudad
tm_shape(bavaria) +
  tm_polygons(col = "D__B_20", palette = pal) +
  tm_facets(by = "Aggregt")

# graficamos los objetos espaciales como puntos
tm_shape(bavaria) +
  tm_dots(
    col = "D__B_20",
    palette = pal,
    popup.vars = TRUE
  ) 


# segunda libreria que probamos es mapview

# graficamos usando funcion mapview
mapview(bavaria)

# especificamos variable para colorear
mapview(bavaria, zcol = "D__B_20")

# especificamos paleta
mapview(bavaria, zcol = "D__B_20", col.regions = pal)

? mapview

# coloreamos de acuerdo al nombre del distrito y generamos un popup
mapview(
  bavaria,
  zcol = "Raumnht",
  col.regions = pal,
  popup = popupTable(
    bavaria,
    zcol = c(
      "D__B_20",
      "B__E_20",
      "Ar_2015"
    )
  )
)



# tercera libreria que probamos sera leaflet

# creamos un mapa por capas
leaflet() %>% # creamos objeto mapa
  addProviderTiles("OpenStreetMap") %>%  # agregamos mapa base
  addPolygons(data = bavaria$geometry, # agregamos los poligonos 
              fillColor  = pal,
              fillOpacity = 1, 
              color = NA)

# agregamos popups
leaflet() %>% 
  addProviderTiles("OpenStreetMap") %>% 
  addPolygons(data = bavaria$geometry, 
              fillColor  = pal,
              fillOpacity = 0.8,
              popup = bavaria$Raumnht, # definimos la variable a expresar (distrito)
              color = "#BDBDC3", 
              weight = 1)

# agregamos opciones de mapa base
leaflet() %>%
  addProviderTiles("OpenStreetMap",
                   group = "OpenStreetMap"
  ) %>%
  addProviderTiles("Stamen.Toner",
                   group = "Stamen.Toner"
  ) %>%
  addProviderTiles("Stamen.Terrain",
                   group = "Stamen.Terrain"
  ) %>% 
  addPolygons(data = bavaria$geometry, 
              fillColor  = pal,
              fillOpacity = 0.8,
              popup = bavaria$Raumnht, # definimos la variable a expresar (distrito)
              color = "#BDBDC3", 
              weight = 1) %>% 
  addLayersControl(
    baseGroups = c(
      "OpenStreetMap", "Stamen.Toner",
      "Stamen.Terrain"),
    # lo ubicamos en la izquierda superior
    position = "topleft"
  )


# creamos un objeto "mapa base" con varias opciones 

basemap <- leaflet() %>%
  addProviderTiles(
    "OpenStreetMap",
    group = "OpenStreetMap"
  ) %>%
  addProviderTiles(
    "Stamen.Toner",
    group = "Stamen.Toner"
  ) %>%
  addProviderTiles(
    "Stamen.Terrain",
    group = "Stamen.Terrain"
  ) %>%
  addProviderTiles(
    "Esri.WorldStreetMap",
    group = "Esri.WorldStreetMap"
  ) %>%
  addProviderTiles(
    "Wikimedia",
    group = "Wikimedia"
  ) %>%
  addProviderTiles(
    "CartoDB.Positron",
    group = "CartoDB.Positron"
  ) %>%
  addProviderTiles(
    "Esri.WorldImagery",
    group = "Esri.WorldImagery"
  ) %>%
  # add a layers control
  addLayersControl(
    baseGroups = c(
      "OpenStreetMap", "Stamen.Toner",
      "Stamen.Terrain", "Esri.WorldStreetMap",
      "Wikimedia", "CartoDB.Positron", "Esri.WorldImagery"
    ),
    position = "topleft"
  )

# usamos el objeto para construir visualizaciones

basemap %>% 
  addPolygons(data = bavaria$geometry, 
              fillColor  = pal,
              fillOpacity = 0.8,
              popup = bavaria$Raumnht,
              color = "#BDBDC3", 
              weight = 1)


# cuarta libreria que usaremos es plotly

# plotly permite convertir ggplot en dinamicos, entre otras funciones

# extraemos un mapa con ggmap
map <- get_stamenmap((st_bbox(bavaria) %>% as.numeric()), 
                     maptype =  'terrain', zoom = 7)

# guardamos el mapa en un objeto p
(p <- ggmap(map) + 
  geom_sf(data = bavaria, aes(fill = B__E_20), inherit.aes = FALSE) +
    scale_fill_gradientn(colours  = pal))

# generamos el mapa dinamico con plotly
ggplotly(p)


# quinta libreria que usaremos es ggiraph, funciona similar a plotly

# creamos el objeto mapa, en esta ocasion usamos el geom_sf_interactive de ggiraph
p2 <- ggmap(map) + 
    geom_sf_interactive(data = bavaria, aes(fill = B__E_20, tooltip=sprintf("%s<br/>%s",Raumnht,B__E_20)), inherit.aes = FALSE) +
    scale_fill_gradientn(colours  = pal)

# creamos un widget html con el grafico
widgetframe::frameWidget(ggiraph(code=print(p2)))


# otras librerias como mapdeck requieren un acceso a su API

# otras herramientas como shiny son mas flexibles pero necesitan ser desarrolladas desde cero
# 
# library(shiny)
# ui <- fluidPage(
#   # front end interface
# )
# server <- function(input, output, session) {
#   # back end logic
# }
# shinyApp(ui = ui, server = server)
