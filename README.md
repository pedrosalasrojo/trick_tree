# "Trick" Conditional Inference Tree

Here we show a function that tricks the Conditional Inference Tree as proposed in Valentini, Brunori, Ferreira and Salas-Rojo (2024)

## Files
function_trick.R: this script contains the function producing the trick-tree. Some comments clarify the arguments to be plugged.

to_run.R: this script runs the function and shows how to get a type partition from the trick-tree. The script computes an trick-tree and obtains a new dataset including the old variables plus the splitting variables and intermediate nodes.

data.csv: data used to run the example.

functions.pdf: document providing details on the function and its implementation in R.

## Description of the example exercise
The example exercise is aimed at showing how to compute an trick-tree as the one proposed in Valentini et al. (2024).

Let's imagine that we want to compute a Conditional Inference Tree (Hothorn et al., 2006) on a sample. In particular, we want to run an IOp model using income as dependent, and sex, ethnicity, fathers education and parental occupation as circumstances. Parental occupation (_parocc_)is an unordered categorical variable with more than 30 values, so the C-Tree algorithm cannot use it (see Valentini et al., 2024)

To estimate IOp we need to trick the algorithm. This code shows a simple exercise to use the trick_tree function, that permits including unordered categorical variables as a regressor, without posing a limit in the number of categories.

First, one needs to define the complete model to be tested. Note that the problematic regressor, the one including more than 30 unordered values, is not stored as factor. The function can be easily modified such that it accepts more than one regressor with more than 30 unordered categories. 

```
model <- income ~ factor(sex) + factor(eth) + factor(fedu) + (parocc) 
```
Run the trick_tree function. The arguments are simple. First, plug the data and the model to be estimated. Plug the name of the variable with unordered categories in "var". The function will transform it so to be used as an ordered categorical. The remainder of the arguments are as defined in the original algorithm by Hothorn et al., (2006) and Hothorn and Zeileis (2015): mincriterion _mincri_ as the confidence level (1-alpha), minbucket _minbu_ as the minimum number of observations accepted on a terminal node, and maximum depth _max_depth_ as the maximum depth allowed in the tree.
```
res <- trick_tree(data = data, model = model, var = "parocc", mincri = 0.99, minbu = 100, max_depth = 5)
```
The function returns the original dataset including two new columns for each step in the depth of the tree:
"splitvar_X" showing the variable used to split the sample and "types_X" showing the binary splittings.
```
type_part <- names(res)[length(res)]
table(res[[type_part]])
```
Finally, estimate IOp on the resulting type partition. First, group by the final type partition and estimate the average. Then, apply a suitable inequality measure.
```
res <- res %>%
  group_by(types_5) %>%
  mutate(y_tilde = mean(income)) %>% ungroup()
print(gini.wtd(res$y_tilde))
```
_Disclaimer_: 

This is a work in progress version. Do not use or cite without checking. This example is drawn for illustrative purposes. Debiased IOp can be obtained using the double debiased procedure (cross-fitting + debiased estimator) proposed in Escanciano and Terschuur (2022).

*References*:

Valentini, A., Brunori, P., Ferreira, F., and Salas-Rojo, P. (2024) Playing the birth lottery in Europe (mimeo)

Escanciano, J. C., and Terschuur, J. R. (2022) "Debiased semiparametric U-statistics: Machine learning inference on inequality of opportunity", ArXiv Preprint arXiv:2206.05235 (Under Review at RESTUD).
