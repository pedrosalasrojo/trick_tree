
# Authors: Annaelena Valentini, Paolo Brunori, Pedro Salas-Rojo
# Date: July 2024 
# Purpose: Trick Tree

# The function trick_tree is used to fit a tricked tree as in Valentini et al. (2024).
# The function takes as input a data frame, a model formula, the name of the vvariable
# to be arranged according to the category averages (e.g. "region"), 
# the mincriterion (default = 0.99), the value of minbucket (default = 100),
# and the maximum depth of the tree (default = 10. 

# The function returns the original dataset including two new columns for each
# step in the depth of the tree:
# "splitvar_X" showing the variable used to split the sample
# "types_X" showing the binary splittings

# Check libraries, install if necessary, and open.

packages <- c("data.table", "partykit", "tm", "tidyverse", "radiant.data") 

for (package in packages) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)
  }
  library(package, character.only = TRUE)
}

# Functions to calculate types with the tricked tree ----

trick_tree <- function(data, model, var,
                       mincri = 0.99, max_depth = 10, minbu = 100){
  
  data$types_0 <- 1  
  data$ID <- seq.int(nrow(data))
  num <- 0
  model <- as.character(model)
  model_new <- as.formula(paste0(model[2], model[1], gsub(var, "permuted", model[3])))
  
  for(d in 1:max_depth){
    
    print(paste0("Depth: ",d))
    ty <- (unique(data[paste0("types_",d-1)]))
    names(ty) <- c("ty")
    ty <- unique(ty$ty)
    
    for (i in ty){
      
      # Get all values that belong to one type (1 "grandparent" and 1 "parent")
      subdata <- filter(data, get(paste0("types_",d-1)) == i)
      
      # Reorder the objective variable according to the expected outcome
      subdata <- subdata %>%
        group_by(!!sym(var)) %>%
        mutate(mean = mean(income)) %>%
        arrange(mean) %>%
        ungroup()
      
      # Get values of the mean
      vals_mean <- unique(subdata$mean)
      
      # Generate permute, that now is numbered according to the mean value
      for(h in 1:length(vals_mean)){
        subdata$permuted[subdata$mean==vals_mean[h]] <- as.numeric(h)
      }
      
      # Get the tree
      tree <- partykit::ctree(model_new,
                              data = subdata, 
                              control = ctree_control(testtype = "Bonferroni", 
                                                      teststat = "quad", 
                                                      mincriterion = mincri,
                                                      minbucket = minbu,
                                                      maxdepth = 1))
      
      # Predict types
      subdata$types <-  predict(tree, type = "node")
      
      # Get how many types we generate with this split
      l_ty <- as.numeric(length(unique(subdata$types)))
      
      # Get values of types and generate new numbers
      val_ty <- unique(subdata$types)
      
      # If it is not a terminal node, print the variable
      if (l_ty == 1){
        
        num <- num + 1
        subdata$types <- ifelse(subdata$types == val_ty[1], num, "NA")
        
        # Generate a value that saves the name of the split
        subdata$splitvar <- "terminal"
        
      } else {
        
        num1 <- num + 1
        num <- num + 2
        
        ct_node <- as.list(tree$node)
        split <- gsub("[[:punct:]]", "",
                      removeWords(names(ct_node[[1]][["info"]][["p.value"]]), 'factor'))
        
        print(paste0("The variable used to split is: ",split))
        
        subdata$types <- ifelse(subdata$types == val_ty[1], num1, num)
        subdata$splitvar <- split
        
      }  
      
      list <- names(data) 
      
      # If in the first split
      if (i == ty[1]){
        
        # Get only variables in "data" (list) + types.
        subdata = subset(subdata, select=c(list, "splitvar", "types"))
        dt<-left_join(data, subdata, by=list)
        
      } else {
        
        subdata = subset(subdata, select=c(list,"splitvar", "types"))
        dt<-left_join(dt, subdata,by=list)
        
        dt <- dt %>% 
          mutate(splitvar = coalesce(splitvar.x,splitvar.y),types = coalesce(types.x,types.y))
        
        dt <- subset(dt, select=(c(list,"splitvar","types")))
      }
    }
    
    data <- dt 
    names(data)[length(data)-1] = paste0("splitvar_",d)
    names(data)[length(data)] = paste0("types_",d)
    
    term <- (unique(data[paste0("splitvar_",d)]))
    names(term) <- c("term")
    t <- unique(term$term)
    
    if (length(t) == 1){
      if (t == "terminal"){
        print(paste0("All nodes are terminal nodes: stop"))
        break
      }
    }
  }
  
  return(`data` = data)
  
}


