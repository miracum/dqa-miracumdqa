# by Lorenz Kapsner
countUnique <- function(data, var, sourcesystem=NULL){
  out <- data.table("variable" = var,
                    "distinct" = data[,nlevels(factor(get(var)))],
                    "valids" = data[!is.na(get(var)),.N],
                    "missings" = data[is.na(get(var)),.N],
                    "sourcesystem" = sourcesystem)
  return(out)
}

# extensive summary
extensiveSummary <- function(vector){
  vector <- as.numeric(as.character(vector))
  
  Q <- stats::quantile(vector, probs=c(.25, .75), na.rm=T, names=F)
  I_out <- stats::IQR(vector, na.rm=T)*1.5
  
  ret <- data.table(rbind(
    c("Mean", round(base::mean(vector, na.rm = T), 2)),
    c("Minimum", round(base::min(vector, na.rm = T), 2)),
    c("Median", round(stats::median(vector, na.rm = T), 2)),
    c("Maximum", round(base::max(vector, na.rm = T), 2)),
    c("SD", round(stats::sd(vector, na.rm = T), 2)),
    c("Negativ", round(as.numeric(base::sum(vector < 0, na.rm = T)), 2)),
    c("Zero", round(as.numeric(base::sum(vector == 0, na.rm = T)), 2)),
    c("Positive", round(as.numeric(base::sum(vector > 0, na.rm = T)), 2)),
    c("OutLo", round(as.numeric(base::sum(vector < (Q[1]-I_out), na.rm = T)), 2)),
    c("OutHi", round(as.numeric(base::sum(vector > (Q[2]+I_out), na.rm = T)), 2)),
    c("Skewness", round(e1071::skewness(vector, na.rm = T), 2)),
    c("Kurtosis", round(as.numeric(e1071::kurtosis(vector, na.rm=T)), 2)),
    c("Variance", round(as.numeric(stats::var(vector, na.rm=T)), 2)),
    c("Range", round(as.numeric(base::max(vector, na.rm=T) - base::min(vector, na.rm=T)), 2))
  ))
  colnames(ret) <- c(" ", " ")
  return(ret)
}

# simple summary
simpleSummary <- function(vector){
  ar <- as.data.frame(as.array(summary(vector)))
  ar[,2] <- as.character(ar[,2])
  colnames(ar) <- c(" ", " ")
  return(ar)
}
