countUnique <- function(data, var, sourcesystem=NULL){
  out <- data.table("variable" = var,
                    "distinct" = data[,nlevels(factor(get(var)))],
                    "valids" = data[!is.na(get(var)),.N],
                    "missings" = data[is.na(get(var)),.N],
                    "sourcesystem" = sourcesystem)
  return(out)
}