
# Authors: Annaelena Valentini, Paolo Brunori, Pedro Salas-Rojo
# Date: July 2024 
# Purpose: Trick Tree

library(dineq)
library(tidyverse)

source("C:/Users/user/Dropbox/BRUNORI&SALAS_/database_github_etc/archive/trick_tree/function_trick.R", echo=TRUE)

data <- read.csv("C:/Users/user/Dropbox/BRUNORI&SALAS_/database_github_etc/archive/trick_tree/data.csv",
                 row.names = 1)

# We want to run an IOp model using income as dependent, and sex, ethnicity,
# fathers education and parental occupation as circumstances.
# Parental occupation is an unordered categorical variable with more than
# 30 values, so the C-Tree algorithm cannot use it (see Valentini et al., 2024)
table(data$parocc)
length(unique(data$parocc))

# To estimate IOp we need to trick the algorithm

# First, define complete model to be tested. Note that the variable to be re-arranged
# in the tree cannot be plugged as factor.
model <- income ~ factor(sex) + factor(eth) + factor(fedu) + (parocc) 

# Estimate Tricked-tree
res <- trick_tree(data = data, model = model, var = "parocc",
                  mincri = 0.99, minbu = 100, max_depth = 5)

# Get last variable (type partition)
type_part <- names(res)[length(res)]
table(res[[type_part]])

# Estimate IOp on the resulting type partition. First, group by the final type
# partition and estimate the average. Then, apply a suitable inequality measure.

res <- res %>%
  group_by(get(type_part)) %>%
  mutate(y_tilde = mean(income)) %>% ungroup()

print(gini.wtd(res$y_tilde))
