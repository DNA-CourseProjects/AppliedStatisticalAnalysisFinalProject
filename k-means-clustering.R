
##############################################################
##############################################################
library(cluster)
library(fpc)


##############################################################
##############################################################
## generate 5 1D objects, divided into 2 clusters.
xx <- c(1,2,3,10,11)
xx
plot(xx)
km=kmeans(xx,c(1,7))
km
plotcluster(xx, km$cluster)
xx
km$cluster
km$centers


##############################################################
##############################################################
## generate 5 2D objects, divided into 2 clusters.
xx <- cbind(rbind(1,2,3,10,11),rbind(1,2,3,10,11))
xx
plot(xx)
km=kmeans(xx,cbind(rbind(2,1),rbind(4,3)),iter.max = 1000)
km
plotcluster(xx, km$cluster) #, method="wnc")
xx
km$cluster
km$centers


##############################################################
##############################################################
## generate 15 1D objects, divided into 2 clusters.
# xx <- rbind(cbind(rnorm(2,0,0.5)), cbind(rnorm(3,5,0.5)))
xx <- rbind(cbind(rnorm(7,0,0.5)), cbind(rnorm(8,5,0.5)))
xx
plot(xx)
km=kmeans(xx,2)
plotcluster(xx, km$cluster)
xx
km$cluster
km$centers


##############################################################
##############################################################
set.seed(4321)
## generate 15 2D objects, divided into 2 clusters.
# xx <- rbind(cbind(rnorm(2,0,0.5)), cbind(rnorm(3,5,0.5)))
xd1 <- rbind(cbind(round(rnorm(7,0,0.5))), cbind(round(rnorm(8,5,1))))
xd1
xd2 <- rbind(cbind(round(rnorm(7,0.5,0.75))), cbind(round(rnorm(8,4,1.5))))
xd2
xx <- cbind(xd1,xd2)
xx

plot(xx)
km=kmeans(xx,3)
plotcluster(xx, km$cluster)
xx
km$cluster
km$centers

##############################################################



##############################################################
set.seed(100)
## generate 15 2D objects, divided into 2 clusters.
# xx <- rbind(cbind(rnorm(2,0,0.5)), cbind(rnorm(3,5,0.5)))
xd1 <- rbind(cbind(round(rnorm(7,0,0.5),2)), cbind(round(rnorm(8,2,1),2)))
xd1
xd2 <- rbind(cbind(round(rnorm(7,1,0.75),2)), cbind(round(rnorm(8,-0.25,2),2)))
xd2
xx <- cbind(xd1,xd2)
xx

#trueGroups = c(rep(1,7),rep(2,8))
grps = seq(1,2)

plot(xx)
km=kmeans(xx,2)
plotcluster(xx, km$cluster)
km$centers

km$cluster

grp1 = km$cluster[1:7]
grp2 = km$cluster[8:15]

grp1Lbl = grp1[which.max(tabulate(match(grp1, unique(grp1))))]
#grp2Lbl = grp2[which.max(tabulate(match(grp2, unique(grp2))))]

#trueGroups = c(rep(1,7),rep(2,8))
trueGroups = c(rep(grp1Lbl,7),rep(grps[-grp1Lbl][1],8))
trueGroups

km$cluster == trueGroups
sum(km$cluster == trueGroups)


##############################################################
##############################################################
km=kmeans(xx,rbind(cbind(0,2),cbind(1,-1)),iter.max = 1000)
#km=kmeans(xx,2)
plotcluster(xx, km$cluster)
xx  
km$centers

km$cluster

grp1 = km$cluster[1:7]
grp2 = km$cluster[8:15]

grp1Lbl = grp1[which.max(tabulate(match(grp1, unique(grp1))))]
grp2Lbl = grp2[which.max(tabulate(match(grp2, unique(grp2))))]

#trueGroups = c(rep(1,7),rep(2,8))
trueGroups = c(rep(grp1Lbl,7),rep(grps[-grp1Lbl][1],8))
trueGroups

km$cluster == trueGroups
sum(km$cluster == trueGroups)


# Compute and plot wss for k = 1 to k = 15

k.max <- 5
wss <- sapply(1:k.max, 
              function(k){kmeans(as.data.frame(xx), k, nstart=10,iter.max = 15 )$tot.withinss})
wss
plot(1:k.max, wss,
     type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")

# function to compute total within-cluster sum of square 
# wss <- function(k) {
#   kmeans(as.data.frame(xx), k, nstart = 10 )$tot.withinss
# }

# k.values <- 1:15
# 
# # extract wss for 2-15 clusters
# wss_values <- map_dbl(k.values, wss)
# 
# plot(k.values, wss_values,
#      type="b", pch = 19, frame = FALSE, 
#      xlab="Number of clusters K",
#      ylab="Total within-clusters sum of squares")


##############################################################
library(e1071)
cm <- cmeans(xx, 2)
cm
head(cm$membership)

# Visualize using corrplot
library(corrplot)
corrplot(cm$membership, is.corr = FALSE)

# Clusters
cm$cluster

library(factoextra)
fviz_cluster(list(data = as.data.frame(xx), cluster=cm$cluster), 
             ellipse.type = "norm",
             ellipse.level = 0.68,
             palette = "jco",
             ggtheme = theme_minimal())


fviz_nbclust(as.data.frame(xx), kmeans, method = "wss")
