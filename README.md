# Getting Started

Install the package or just source R/read.R.


We read a history file, including the comments.
```r
f = system.file("sampleCode", "eg1", package = "RCommandAnalysis")
exprs = readCode(f)
```
`exprs` is now a list with each of the elements
being either a call, =, or some language object, 
or a Comment object.
```r
sapply(exprs, class)
```
```
 [1] "call"    "call"    "Comment" "call"    "="       "call"   
 [7] "call"    "Comment" "call"    "call"   
```

Now, we convert this to a data frame with a row for each function
called or a comment:
```r
df = longDF(exprs)
df
```

```
   lineNum               comment functions
1        1                  <NA>     getwd
2        2                  <NA>     setwd
3        3 # this is a comment\n      <NA>
4        4                  <NA>         :
5        5                  <NA>     rnorm
6        6                  <NA>      plot
7        7                  <NA>      plot
8        7                  <NA>     rnorm
9        7                  <NA>       log
10       7                  <NA>       abs
11       8   # another comment\n      <NA>
12       9                  <NA>         :
13      10                  <NA>         q
```

The first column gives the line/expression/command numbers.
Note that 7 appears 4 times and this is because
this corresponds to the nested command
```
plot(rnorm(log(abs(x))))
```
So there are 4 functions being called here.



Comments are identified in the comment column.
When comment is `NA`, the functions column should have a value.

This could be more general and we can compute
lots of other interesting information from the
info parameter in longDF().
