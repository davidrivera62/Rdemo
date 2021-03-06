library(dataseries)
library(forecast)
library(ggplot2)

acc.model <- function(
  datos,                  #Columna de datos de la serie de tiempo
  fechas,                 #Columna de fechas de la serie de tiempo
  frequency,              #Frecuencua atribuida a la serie de tiempo
  m,                      #Cantidad de periodos a pronosticar
  ano.inicio,             #ano inicio estimacion
  periodo.inicio,         #Periodo inicio estimacion
  number.model            #Numero modelo a seleccionar
){

  y <- ts(data = datos,frequency = frequency, start = c(ano.inicio, periodo.inicio))

  n <- length(y)

  yi <- ts(y[1:(n-m)],frequency=frequency)
  yf <- ts(y[(n-m+1):n],frequency=frequency)

  fechas.model <- fechas[1:(n-m)]
  fechas.pron <- fechas[(n-m+1):n]

  ti <- seq(1:length(yi))
  ti2 <- ti*ti
  ti3 <- ti*ti*ti
  It <- seasonaldummy(yi)

  T <- length(yi)
  Itf <- seasonaldummy(yi,m)
  tf <- seq(T+1,T+m,1)
  tf2 <- tf*tf
  tf3 <- tf*tf*tf

  if (number.model == 1){

    model <- lm(yi ~ ti)
    Xtf <- cbind(rep(1,m),tf)
    ypron <- predict(model, newdata = list(ti = tf))
    ypron <- ts(ypron,frequency = frequency)

  } else if (number.model == 2){

    model <- lm(yi ~ ti + ti2)
    ypron <- predict(model, newdata = data.frame(ti=tf,ti2=tf2))
    ypron <- ts(ypron,frequency = frequency)

  } else if (number.model == 3){

    model <- lm(yi ~ ti + ti2 + ti3)
    ypron <- predict(model, newdata = data.frame(ti=tf, ti2=tf2, ti3=tf3))
    ypron <- ts(ypron,frequency = frequency)

  } else if (number.model == 4) {

    model <- lm(yi ~ ti + It)
    ypron <- predict(model, newdata = data.frame(cbind(data.frame(ti=tf),It=I(Itf))))
    ypron <- ts(ypron,frequency = frequency)

  } else if (number.model == 5){

    model <- lm(yi ~ ti + ti2 + It)
    ypron <- predict(model, newdata = data.frame(cbind(data.frame(ti=tf,ti2=tf2),It=I(Itf))))
    ypron <- ts(ypron,frequency = frequency)

  } else {

    model <- lm(yi ~ ti + ti2 + ti3 + It)
    ypron <- predict(model, newdata = data.frame(cbind(data.frame(ti=tf,ti2=tf2,ti3=tf3),It=I(Itf))))
    ypron <- ts(ypron,frequency = frequency)
  }

  return(data.frame(t(accuracy(ypron,yf))))

}
