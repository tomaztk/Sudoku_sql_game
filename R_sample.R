

mat = matrix(c(12,11,23,23,34,35,51,55,56),nrow = 3, ncol = 3,byrow = TRUE)
print(mat)

for (i in 1:3){
  for (j in 1:3){
    print(mat[i,j])
  }
}



for (i in 1:3){
  for (j in 1:3){
    if (mat[i,j] == 23){
      print(paste("true", i, j, sep = " "))
    } else {
      print (paste("not exists", i, j, sep = " "))
    }
  }
}
