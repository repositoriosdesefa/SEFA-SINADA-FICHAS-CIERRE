####################################################################
#           GENERACION DE FICHAS DE CIERRE SINADA                 ##
####################################################################

# I. LIBRERIAS A UTILIZAR----


#install.packages("dplyr")
library(dplyr)
#install.packages("lubridate")
library(lubridate)
#install.packages("readxl")
library(readxl)
#install.packages("stringr")
library(stringr)
#install.packages("purrr")
library(purrr)
#install.packages("blastula")
library(blastula)
#install.packages("kableExtra")
library(kableExtra)
#install.packages("googledrive")
library(googledrive)
#install.packages("googlesheets4")
library(googlesheets4)
#install.packages("httpuv")
library(httpuv)
library(WriteXLS)
library(readxl)
library(openxlsx)
library(ggplot2)
library(reshape2)
library(knitr)
library(forcats)
library(rmarkdown)
library(filesstrings)


# II. IMPORTANDO Y GUARDANDO DATA
## II.1 INGRESANDO A CUENTA----


correo_usuario <- ""
drive_auth(email = correo_usuario) 
gs4_auth(token = drive_auth(email = correo_usuario), 
         email = correo_usuario)

## II.2 CONECTANDO CON LA BASE DE DATOS----

SEGUIMIENTO <- ""
DERIVACIONES<- as.data.frame(read_sheet(SEGUIMIENTO, sheet = ""))

CALCULADORA <- ""
tp1 <- tempfile()
download.file(CALCULADORA, tp1, mode ="wb")
CALCULADORA <- as.data.frame(read_xlsx(tp1, sheet = ""))

POI <- ""
tp1 <- tempfile()
download.file(POI, tp1, mode ="wb")
POI <- as.data.frame(read_xlsx(tp1, sheet = ""))

## II.3 DESCARGANDO BASE DE DATOS----

write.xlsx(DERIVACIONES,file="DERIVACIONES.xlsx", sheetName="DERIVACIONES")
write.xlsx(CALCULADORA,file="CALCULADORA.xlsx", sheetName="CALCULADORA")
write.xlsx(POI,file="POI.xlsx", sheetName="POI")



# III. LIMPIANDO DATA----


CALCULADORA_FILTRADA <- select(
  CALCULADORA,
  DENUNCIA = 'CODIGO_SINADA_FINAL',
  DEPARTAMENTO = 'DEPARTAMAMENTO (automático)',
  PROVINCIA = 'PROVINCIA (automático)',
  DISTRITO = 'DISTRITO (automático)',
  COMPONENTE = 'COMPONENTE',
  AGENTE = 'AGENTE',
  ACTIVIDAD = 'ACTIVIDAD',
  EXTENSION = 'EXTENSIÓN',
  UBICACION = 'UBICACIÓN',
  OCURRENCIA = 'OCURRENCIA',
  Resultado = 'Resultado',
  Amerita_seguimiento = 'Amerita seguimiento',
  Observaciones = 'Observaciones(opcional)',
  Especialista = 'Especialista (obligatorio)',
  Para_emitir = 'GENERAR',
  HT_TRASLADO = 'HT DE TRASLADO (obligatorio)',
  Fecha_cierre = 'Fecha cierre'
)

LISTA <- filter(CALCULADORA_FILTRADA, CALCULADORA_FILTRADA$Para_emitir == "Si")

DATOS_DENUNCIA <- data.frame(
  "DENUNCIA" = LISTA $DENUNCIA,
  "ESPECIALISTA" = LISTA $Especialista)

DATOS_DENUNCIA2 <- distinct(DATOS_DENUNCIA)

# IV. GUARDANDO INFORMACION POR ESPECIALISTA----


## ESPECIALISTAS
denuncias_karem <- DATOS_DENUNCIA2 %>% filter(ESPECIALISTA == "")
karem_denuncias <- as.data.frame(denuncias_karem)
write.xlsx(karem_denuncias,file="xlsx", sheetName="DATA")



write.xlsx(DATOS_DENUNCIA2,file="DATOS_DENUNCIA2.xlsx", sheetName="DATA")



# V. REPRODUCCION DE FICHAS----

# ESPECIALISTA1

Datadenuncias <- read_excel(".xlsx")

denuncia2 <- select(
  Datadenuncias,
  denuncia2 = 'DENUNCIA'
)

denuncia2 <- denuncia2$denuncia2

# Definir función para generación de reportes
for ( i in denuncia2 ) {
  rmarkdown :: render ( "Fichas_Cierre_RMD.Rmd" ,
                        params  =  list(denuncia2=i),
                        output_file  = paste0 ("Ficha_Cierre_", i)
  )
}


#################################################################### 
#              ENVIO DE CORREOS                                    #
####################################################################

# I. Email: Cabecera ----
Arriba <- add_image(
  file = "https://imgur.com/bzABYet.png",
  width = 1000,
  align = c("right"))
Cabecera <- md(Arriba)

# II. Email: Pie de página ----
Logo_Oefa <- add_image(
  file = "https://i.imgur.com/ImFWSQj.png",
  width = 280)
Pie_de_pagina <- blocks(
  md(Logo_Oefa),
  block_text(md("Avenida Faustino Sánchez Carrión N° 603, 607 y 615 - Jesús María"), align = c("center")),
  block_text(md("Teléfonos: 204-9900 Anexo 7154"), align = c("center")),
  block_text("www.oefa.gob.pe", align = c("center")),
  block_text(md("**Síguenos** en nuestras redes sociales"), align = c("center")),
  block_social_links(
    social_link(
      service = "Twitter",
      link = "https://twitter.com/OEFAperu",
      variant = "dark_gray"
    ),
    social_link(
      service = "Facebook",
      link = "https://www.facebook.com/oefa.peru",
      variant = "dark_gray"
    ),
    social_link(
      service = "Instagram",
      link = "https://www.instagram.com/somosoefa/",
      variant = "dark_gray"
    ),
    social_link(
      service = "LinkedIn",
      link = "https://www.linkedin.com/company/oefa/",
      variant = "dark_gray"
    ),
    social_link(
      service = "YouTube",
      link = "https://www.youtube.com/user/OEFAperu",
      variant = "dark_gray"
    )
  ),
  block_spacer(),
  block_text(md("Imprime este correo electrónico sólo si es necesario. Cuidar el ambiente es responsabilidad de todos."), align = c("center"))
)

# III. Email: Cuerpo del mensaje ----
cta_button <- add_cta_button(
  url = "",
  text = "Ficha de cierre - SINADA"
)
Cuerpo_del_mensaje <- blocks(
  md("
Estimados,

Las fichas de cierre con la información extraída de las bases de datos del Sinada y la calculadora de impacto de problemáticas fueron generadas con éxito.
Ustedes pueden acceder a las mismas desde el siguiente enlace:"
  ),
  md(c(cta_button)),
  md("


***
**Tener en cuenta:**
- Este correo electrónico ha sido generado de manera automática por un archivo R Script.
- La carpeta compartida contiene las fichas de cierre por especialista.
- Si la ficha una vez revisada no cuenta con errores, se deberá colocar en la matriz de la calculadora la opción: Sí, en la columna denominada Ficha elaborada.
- En caso se encuentre con la opción: No, en la columna denominada Ficha elaborada, revisar que los campos en las matrices esten correctamente ingresados.
- Modificar en el Siged la HT donde se ubicará la ficha de cierre, esto a través de la opción Modificar en la que se deberá colocar en el campo Título el siguiente párrafo: Ficha de cierre SC-XXXX-2020.
     ")
)

# IV. Email: Composición ----

email <- compose_email(
  header = Cabecera,
  body = Cuerpo_del_mensaje, 
  footer = Pie_de_pagina,
  content_width = 1000
)


# Email: Envío ----
Destinatarios <- c(
  ""
)
Destinatarios_cc <- c(
  ""
)

Asunto <- paste("Fichas de cierre - SINADA | ", now())
smtp_send(
  email,
  to = Destinatarios,
  from = c("SEFA - OEFA" = ""),
  subject = Asunto,
  cc = Destinatarios_cc,
  credentials = creds_key(id = ""),
  verbose = TRUE
) 

