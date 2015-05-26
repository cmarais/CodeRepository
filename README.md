# TechnicalInterview

This repository contains the code for the Decisions Science and Analytics technical interview.

The repository is structured in two sections.  The sections contain the following:

1) Matlab

This section contains two pieces of code.  

The first code is called 'solve_model.m'.  This piece of code is drawn from my PhD thesis.  In my thesis, I developed a model of an open-pit mining firm's decision to invest in a new pit given uncertainty regarding commodity prices and the geological distribution of ore.  This code implements dynamic programming to determine the probability in each state of the model that a mining firm will choose to open a new pit, or remain in the same pit.

The second piece of code is called 'policy_analysis_graph_level.m'.  This piece of code is used to create a graph of the probabilities for different actions generated in the above piece of code.  The pdf file in the folder is an example of what such a graph looks like.

2) R

This section contains one piece of code called 'fun_dynforecast_exponent.R'.  This code is designed to forecast a non-linear model in out-of-sample forecasts when the lag of the dependent variable is an explanatory variable.  The model takes the form: yt = b0 + exp(b1*exp(y(t-1))) + b2x1 + b3x2 + ...



