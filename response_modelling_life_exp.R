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


# 1. Model the response variable “Income” and find the best model explaining its variation.


# 2. Model the response variable “Life Exp” and find the best model explaining its variation.


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

feature_combinations <- lapply(1:length(colnames(data)), function(k) combn(colnames(data), k, simplify = FALSE))
all_combinations <- unlist(feature_combinations, recursive = FALSE)
all_combinations[[10]]
length(all_combinations)


response_var <- "Life Exp"

text_c <- c()
predictors <- c()
  r_sq <- c()
adj_r_sq <- c()
f_scores <- c()

# Check normality of residuals!!!
for(i in 1:length(all_combinations))  {
    features_str <- ""
    feature_set <- all_combinations[[i]]
    
    if ( any(feature_set == response_var) ) {
      next
    }
    
    colnames(data) 
    feature_set
    feature_set
    setdiff(colnames(data), feature_set)
    missing_feats <- setdiff(colnames(data), feature_set)
    cat(" Missing features are " , toString(missing_feats) , "\n")
    toString(missing_feats)
    
    length(feature_set)
    for(j in 1:length(feature_set)) {
      cat(" j = " , j, " `" , feature_set[j], "`\n")
      if(j >1) {
        features_str <- paste0( features_str, " + `" ,  feature_set[j], "`")
        
      }else {
        features_str <- paste0( features_str, "`", feature_set[j], "`")
      }
      
    }
    features_str <- paste0( "`" , response_var , "`" ,  " ~ " , features_str)
    cat("Features_str is " , features_str , "\n")
    exp <- expression(features_str)
    
    eval(features_str)
    formula_str <- as.formula(features_str)
    model <- lm(formula=features_str , data=data)
    model_sum <- summary(model)
    output <- paste(capture.output(model_sum), collapse="\n")
    output
    
    
    predictors <- c(predictors, length(feature_set))
    text_c <- c(text_c , paste0(" Formula: " ,
                                toString(features_str) ,
                                " \n ",
                                " Missing features: " ,
                                toString(missing_feats) ,
                                "\n" ,
                                output))
    r_sqs <- c(r_sqs , model_sum$r.squared)
    adj_r_sq <- c(adj_r_sq , model_sum$adj.r.squared)
    f_scores <- c(f_scores , model_sum$fstatistic[1])
}
length(f_scores)
length(text_c)
text_c


text_c[which.max(adj_r_sq)]

# length(predictors)
length(adj_r_sq)
predictors
plot_ly(data, x = ~predictors, y = ~adj_r_sq, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5
        ),
       # color=f_scores,
        text=text_c, hoverinfo="text") %>%
  layout(title = "Life Expectancy models' \n Adjusted R^2 vs Number of Variables ",
         xaxis = list(title = "Number of Variables"),
         yaxis = list(title = "Life Expecancy models' Adjusted R^2"),
         hoverlabel = list(font = list(family = "Arial", size = 10))
         )

best_predictors <- c("Population" , "Murder" , "`HS Grad`" , "Frost")

all_excpt_resp <- gsub(response_var, "" , colnames(data))
all_excpt_resp <- all_excpt_resp[nzchar(all_excpt_resp)]
all_excpt_resp
for(i in 1:length(all_excpt_resp)) {
  all_excpt_resp[i] <- paste0("`" , all_excpt_resp[i] , "`")
}
all_excpt_resp


  best_simple_model_str <- paste0("`" , response_var , "`" ,  " ~ " , paste0(best_predictors, collapse=" + ") )

interactions <- combn(all_excpt_resp, 2, paste, collapse = ":")
print(interactions)
length(interactions)

text_c <- c()
predictors <- c()
r_sq <- c()
adj_r_sq <- c()
f_scores <- c()

pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = length(interactions) , # Maximum value of the progress bar
                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                     width = 50,   # Progress bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar

n <- 1


best_model_str <- best_simple_model_str
best_model_str
best_display_model_str <- best_simple_model_str
best_predictors <- c()
avail_ints <- interactions
avail_ints[avail_ints != "`Population`:`Income`"]

while(n < 19) {
  
    combinations <- combn(avail_ints, 1, paste, collapse = ", ")
    combinations
    local_adj_r_sq <- c()
    for(j in 1:length(avail_ints)) {
      avail_ints
      
      avail_ints[j]
     int_model_str <- paste0(best_model_str ,
                                  " + " , 
                                  avail_ints[j]
                                      )
     display_model_str <-  paste0(best_display_model_str ,
                                  " + \n" , 
                                  avail_ints[j]
                                      )
     int_model <- lm(int_model_str, data=data)
     int_model_str
     
     model_sum <- summary(int_model)
     model_sum
     
      output <- paste(capture.output(model_sum), collapse="\n")
      output
      predictors <- c(predictors, length(best_predictors) + 1)
      text_c <- c(text_c , paste0(" Formula: " ,
                                  display_model_str ,
                                  " \n ",
                                  # " Missing features: " ,
                                  # toString(missing_feats) ,
                                  "\n" ,
                                  output))
      r_sqs <- c(r_sqs , model_sum$r.squared)
      adj_r_sq <- c(adj_r_sq , model_sum$adj.r.squared)
      local_adj_r_sq <- c(local_adj_r_sq , model_sum$adj.r.squared)
      f_scores <- c(f_scores , model_sum$fstatistic[1])
    }
    
    which.max(adj_r_sq)
    adj_r_sq[3]
    
    max_int <- avail_ints[which.max(local_adj_r_sq)]
    max_int
    
    avail_ints <- avail_ints[avail_ints != max_int]
    avail_ints
    best_predictors <- c(best_predictors, combinations[which.max(adj_r_sq)])
    best_model_str <- paste(best_model_str, " + " , max_int
                             )
    
    best_display_model_str <- paste(best_display_model_str, " + \n " , max_int)
    
    # setTxtProgressBar(pb, i)
  n <- n + 1
}

best_model_str

plot_ly(data, x = ~predictors, y = ~adj_r_sq, type = 'scatter', mode = 'markers',
        marker = list(size = 10, opacity = 0.5
        ),
       # color=f_scores,
        text=text_c, hoverinfo="text") %>%
  layout(title = "Life Expectancy models' \n Adjusted R^2 vs Number of Interaction Terms ",
         xaxis = list(title = "Number of Interaction Terms"),
         yaxis = list(title = "Life Expecancy models' Adjusted R^2"),
         hoverlabel = list(font = list(family = "Arial", size = 10), borderwidth = 1)
         )


text_c[which.max(adj_r_sq)]
print(combinations)

data$Income
data$`Life Exp`
