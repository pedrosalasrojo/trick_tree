# "Trick" Conditional Inference Tree

Here we show a function that tricks the Conditional Inference Tree as proposed in Valentini, Brunori, Ferreira and Salas-Rojo (2024)

## Files
function_trick.R: this script contains the function producing the trick-tree. Some comments clarify the arguments to be plugged.

to_run.R: this script runs the function and shows how to get a type partition from the trick-tree. The script computes an trick-tree and obtains a new dataset including the old variables plus the splitting variables and intermediate nodes.

data.csv: data used to run the example.

## Description of the example exercise
The example exercise is aimed at showing how to compute an trick-tree as the one proposed in Valentini et al. (2024).

Let's imagine that we want to compute a Conditional Inference Tree (Hothorn et al., 2006) on a sample using a set of circumstance variables as regressors. One 


_Disclaimer_: This is a work in progress version. Do not use or cite without checking.

*References*:
Valentini, A., Brunori, P., Ferreira, F., and Salas-Rojo, P. (2024) Playing the birth lottery in Europe (mimeo)
