library(stringr)
library(webshot)
library(plotly)
library(GGally)
library(cluster.datasets)
library(latex2exp)
data(state)
state.x77
is.matrix(state.x77)

data <- as.data.frame(state.x77)


ggpairs(data, title="Correlogram of states' data")

# 1. Model the response variable “Income” and find the best model explaining its variation.


# 2. Model the response variable “Life Exp” and find the best model explaining its variation.



########################################
# 3. Group the sates based on their Income.
# Group 1: Income ≤ 4000,
# Group 2: 4000 < Income ≤ 5000,
# Group 3: 5000 < Income.


inc_group <- c()
for(i in 1:length(data$Income) ) {
  group = 1
  income = data$Income[i]
  if(income < 4000) {
    group = "Low Inc"
  }else if(income > 4000 && income <= 5000) {
    group = "Med Inc"
  }else if (income > 5000)  {
    group = "High Inc"
  }
  inc_group <- c(inc_group , group)
}
inc_group

data_aug <-  data
data_aug$IncGroup = as.factor(inc_group)
data

# Use analysis of variance (ANOVA) to show whether the average “Life Exp” is different
# among these groups. If yes, what groups are different?

frmla <- formula("`Life Exp` ~ IncGroup")
one.way <- aov(formula=frmla, data=data_aug)
summary(one.way)

tukey.one.way<-TukeyHSD(one.way)
tukey.one.way

png("./plots/boxplot-income_v_lifexp.png")
boxplot(data_aug$`Life Exp`~data_aug$IncGroup,data=data_aug,
        main="Box Plot of Life Expectancy Versus Income Group",
        xlab = "Income Group \n (based on per capita income in 1974 USD)" ,
        ylab="Life Expectancy (years)",
        xaxt="n"
        )
str <- "$0 < x \\le 4000$"
xtick_labels <- c(TeX("$0 < x \\leq 4000$"), TeX("$4000 < x \\leq 5000$") , TeX("$ x > 5000$"))
axis(1,at=1:length(xtick_labels), labels=xtick_labels )
dev.off()

########################################
#   Use analysis of variance to show whether the average “HS Grad” is different among these
# groups. If yes, what groups are different?

frmla <- formula("`HS Grad` ~ IncGroup")
one.way <- aov(frmla, data=data_aug)
summary(one.way)

tukey.one.way<-TukeyHSD(one.way)
tukey.one.way

png("./plots/boxplot-hsgrad_v_inggroup.png")
boxplot(data_aug$`HS Grad`~data_aug$IncGroup,data=data_aug,
        main="Box Plot of High School Graduation Percentage \n Versus Income Group",
        xlab = "Income Group \n (based on per capita income in 1974 USD)" ,
        ylab="High School Graduation Percentage (1970)",
        xaxt="n"
        )
str <- "$0 < x \\le 4000$"
xtick_labels <- c(TeX("$0 < x \\leq 4000$"), TeX("$4000 < x \\leq 5000$") , TeX("$ x > 5000$"))
axis(1,at=1:length(xtick_labels), labels=xtick_labels )
dev.off()


#   4. Divide the dataset to different groups using K-Means and Fuzzy C-Means clustering. What
# features were useful for clustering?
colnames(data)
features <- c("Murder", "Income" , "Population", "HS Grad")

feature_names <- c( "Murder"="Murder/Manslaughter Rate (1976)", 
  "Income"="Income (per capita, 1974)",
  "Population"="Population Estimate 1975",
  "Income"="Income (per capita 1974)",
  "Illiteracy"="Illiteracy (1970, percent of population)",
  "Life Exp"="Life Expectancy in years \\n (1969-71)",
  "HS Grad"="High School Graduation Rate (1970)",
  "Frost"="Avg. # of days with min temp below freezing (1931-1960)",
  "Area"="land area in square miles"
)


avg_within_vars <- c()
ks <- c()
bet_by_tot <- c()
bet_ss <- c()
tot_ss <- c()
tot_wit <- c()
size <- c()
iter <- c()
feat_strs <- c()

feature_combinations <- lapply(1:length(colnames(data)), function(k) combn(colnames(data), k, simplify = FALSE))
all_combinations <- unlist(feature_combinations, recursive = FALSE)
all_combinations[[10]]
length(all_combinations)

k <- 2
for(k in 2:15) {
    
  for(i in 1:length(all_combinations)) 
    {
    feature_set <- all_combinations[[i]]
    feature_set
    # cat(" feature set is  " , feature_set , "\n")
    # print(typeof(feature_set))
    feature_set <- unlist(feature_set)
    feature_set
    data_features <- data[, feature_set]
    data_features
    features_str <- toString(feature_set)
    mod_feat_str <- gsub(" ", "", features_str)
    mod_feat_str <- gsub(",", "+", features_str)
    kmeans_result <- kmeans(data_features, centers = k)
    # kmeans_result
    # kmeans_result$tot.withinss
    # kmeans_result$centers
    # 
    bet_cluster_perc <- round( kmeans_result$betweenss / (kmeans_result$tot.withinss + kmeans_result$betweenss),
                               digits=4)
  
  
    # within_vars <- c(within_vars, kmeans_result$withinss)
    median(kmeans_result$withinss)
    avg_within_vars <- c(avg_within_vars, mean(kmeans_result$withinss))
    ks <- c(ks, k)
    bet_by_tot <- c(bet_by_tot, bet_cluster_perc)
    bet_ss <- c(bet_ss, kmeans_result$betweenss)
    tot_ss <- c(tot_ss, kmeans_result$totss)
    tot_wit <- c(tot_wit , kmeans_result$tot.withinss)
    size_str <-  toString(kmeans_result$size)
    size_str <- gsub(",", "+" , size_str)
    size_str <- gsub(" ", "" , size_str)
    size_str
    size <- c(size, size_str)
    iter <- c(iter, kmeans_result$iter)
    feat_strs <- c(feat_strs, mod_feat_str)
  
    latex_str <- paste0(" Plot of k-means clustering using \n " ,
                        features_str,
                        " \n  with  k = " ,
                        k,
                        " Between Cluster Percentage =", bet_cluster_perc )
    # plot_title <- TeX(latex_str)
    plot_title <- latex_str
    plot_title
  
    filename_str <- paste0("becp=" ,bet_cluster_perc,  "k=", k, "_feat=(",  mod_feat_str ,  ")" , ".png")
    filename_str <- paste0("./plots/kmeans/", filename_str)
    filename_str
    png(filename_str)
    plotcluster(data_features,
                kmeans_result$cluster,
                # xlab = feature_names[features[1]],
                # ylab = feature_names[features[2]],
                pch = kmeans_result$cluster,
                )
    mtext(plot_title, side = 3, line = 1, adj = 0.5,)
    dev.off()
  }
}
    
#   data_features <- data[, features]
#   
#   features
#   features_str <- toString(features)
#   mod_feat_str <- gsub(" ", "", features_str)
#   mod_feat_str <- gsub(",", "+", features_str)
#   
#   kmeans_result <- kmeans(data_features, centers = k)
#   kmeans_result
#   kmeans_result$tot.withinss
#   kmeans_result$centers
#   
#   bet_cluster_perc <- round( kmeans_result$betweenss / (kmeans_result$tot.withinss + kmeans_result$betweenss),
#                              digits=4)
#   
#   
#   # within_vars <- c(within_vars, kmeans_result$withinss)
#   median(kmeans_result$withinss)
#   avg_within_vars <- c(avg_within_vars, mean(kmeans_result$withinss))
#   ks <- c(ks, k)
#   bet_by_tot <- c(bet_by_tot, bet_cluster_perc)
#   bet_ss <- c(bet_ss, kmeans_result$betweenss)
#   tot_ss <- c(tot_ss, kmeans_result$totss)
#   tot_wit <- c(tot_wit , kmeans_result$tot.withinss)
#   size_str <-  toString(kmeans_result$size)
#   size_str <- gsub(",", "+" , size_str)
#   size_str <- gsub(" ", "" , size_str)
#   size_str
#   size <- c(size, size_str)
#   iter <- c(iter, kmeans_result$iter)
#   feat_strs <- c(feat_strs, mod_feat_str)
#   
#   latex_str <- paste0(" Plot of k-means clustering using \n " ,
#                       features_str, 
#                       " \n  with  k = " ,
#                       k, 
#                       " Between Cluster Percentage =", bet_cluster_perc )
#   # plot_title <- TeX(latex_str)
#   plot_title <- latex_str
#   plot_title
#   
#   filename_str <- paste0( "k=", k, "_feat=(",  mod_feat_str ,  ")_bcp=" , bet_cluster_perc, ".png")
#   filename_str <- paste0("./plots/kmeans/", filename_str)
#   filename_str
#   png(filename_str)
#   plotcluster(data_features,
#               kmeans_result$cluster,
#               # xlab = feature_names[features[1]],
#               # ylab = feature_names[features[2]],
#               pch = kmeans_result$cluster,
#               )
#   mtext(plot_title, side = 3, line = 1, adj = 0.5,)
#   dev.off()
# }

  


avg_within_vars

cluster_df <- data.frame(
avg_within_vars  = avg_within_vars,
ks = ks,
bet_by_tot = bet_by_tot,
bet_ss = bet_ss,
tot_ss = tot_ss,
tot_wit = tot_wit,
size = size,
iter = iter,
features=feat_strs
)

features

nrow(cluster_df) # 14 * 255
save(cluster_df , file="./kmeans_clustering_results.csv")


features_lengths <- c()
text_c <- c()
features_str
for(i in 1:length(cluster_df$features)) {
  plus_count <- str_count(cluster_df$features[i], "\\+")
  # features_lengths <- c(features_lengths, paste0(toString(plus_count + 1 ) , " variables" ))
  features_lengths <- c(features_lengths, plus_count + 1 )
  text <- paste0("<b>Within Cluster Sum of Squares: </b> ", round(cluster_df$bet_ss[i], digits=2),"\n",
                 "<b>Total Sum of Squares: </b> " , round(cluster_df$tot_ss[i],digits=2), "\n",
                 "<b>Total Within Cluster Sum of Squares: </b>" , round(cluster_df$tot_wit[i], digits=2), "\n",
                 "<b>Between Sum of Squares Divided By Total</b>" , round(cluster_df$bet_by_tot[i], digits=4), "\n",
                 "<b>Features: </b>" , cluster_df$features[i] , "\n" , 
                 "<b>Sizes: </b>", cluster_df$size[i], "\n",
                 "<b>K: </b>" , cluster_df$ks[i], "\n",
                 "<b>Average Within Cluster Variance:</b>" , cluster_df$avg_within_vars[i], "\n"
                 )
  
  text_c <- c(text_c , text )
}

png("./plots/k-vs-bet_by_tot.png")
plot_ly(cluster_df, x = ~ks, y = ~bet_by_tot, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5), text=text_c, hoverinfo="text", color=features_lengths) %>%
  layout(title = "Percentage of explained variation over total variation vs number of centers ",
         xaxis = list(title = "k (number of centers)"),
         yaxis = list(title = "Percentage of sum of squared by total sum of squared"))

dev.off()


features_lengths

png("./plots/k-vs-avg_within_vars.png")
webshot::install_phantomjs()
fig1 <- plot_ly(cluster_df, x = ~ks, y = ~avg_within_vars, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5), color=features_lengths, text=text_c, hoverinfo="text") %>%
  layout(title = "Average within cluster variation vs number of centers",
         xaxis = list(title = "k (number of centers)"),
         yaxis = list(title = "Average within cluster variation"))
fig1
dev.off()

cluster_df$tot_wit
plot_ly(cluster_df, x = ~ks, y = ~tot_wit, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5),color=features_lengths, text=text_c, hoverinfo="text") %>%
  layout(title = "Total within cluster variation vs number of centers",
         xaxis = list(title = "k (number of centers)"),
         yaxis = list(title = "Total within cluster variation"))


plot_ly(cluster_df, x = ~features_lengths, y = ~tot_wit, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5),color=features_lengths, text=text_c, hoverinfo="text") %>%
  layout(title = "Total within cluster variation vs number of variables",
         xaxis = list(title = "number of variables"),
         yaxis = list(title = "Total within cluster variation"))

plot_ly(cluster_df, x = ~features_lengths, y = ~avg_within_vars, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5),color=features_lengths, text=text_c, hoverinfo="text") %>%
  layout(title = "Average within cluster variation vs number of variables",
         xaxis = list(title = "number of variables"),
         yaxis = list(title = "Average within cluster variation"))


cluster_df$
plot_ly(cluster_df, x = ~features_lengths, y = ~avg_within_vars, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5),color=features_lengths, text=text_c, hoverinfo="text") %>%
  layout(title = "Average within cluster variation vs number of variables",
         xaxis = list(title = "number of variables"),
         yaxis = list(title = "Average within cluster variation"))


plot_ly(cluster_df, x = ~features_lengths, y = ~bet_by_tot, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5), text=text_c, hoverinfo="text", color=features_lengths) %>%
  layout(title = "Percentage of explained variation over total variation vs number of variables ",
         xaxis = list(title = "number of variables"),
         yaxis = list(title = "Percentage of sum of squared by total sum of squared"))
#   Due: Fri, June 16
# Use the posted template for the project report.
