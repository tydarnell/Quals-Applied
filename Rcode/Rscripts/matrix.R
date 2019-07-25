sscp=function(x){
  xx=t(x)%*%x
  d=diag(diag(xx))
  d2=diag(diag(d^(-.5)))
  res=d2%*%xx%*%d2
  colnames(res)=colnames(x)
  res
}

cindex=function(l){
  res=c(1:length(l))
  for (i in seq_along(l)) {
   res[i]=sqrt(l[1]/l[i])
  }
  res
}

eigenvi=function(mat){
  eig=eigen(mat)$values
  cind=cindex(eig)
  res=cbind(eig,cind)
  colnames(res)=c('Eigenvalues','Condition Index')
  res
}