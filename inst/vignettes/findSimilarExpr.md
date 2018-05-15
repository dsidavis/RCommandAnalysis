

We start with Deb's prepared code from the class.
```
deb = readRDS("DebsCode.rds")
```


We load the information from all of the students history files into R
already processed by RHistoryAnalysis. This is `rw`.
```
rw = readRDS("baseRaw.rds")
```
This is a single data.frame with columns ID, date, src, expr, isInlineComment, isComment, lineNum.
We'll pull out one student - ID == 31 and the first day of the workshop
```
s31 = rw[ rw$ID==31 & rw$date == 19,]
```
To make other computations easier later on, we will add a column
which gives the command number for a student.
```
s31$cmdNum = seq(length = nrow(s31))
```
When we get a particular row back from our functions,
we now can determine where it came from in the original data
frame. ( We could also use the original row names.)
(We also have this in lineNum, but is that exactly the same thing.)
The reason we want this is to be able to find the all the
rows after this one, but before the next entirely different command,
i.e., find the rows in the data frame that are related to the same command,
as varitions of the same command.


We'll start with an interesting command in Deb's code:
```
simpleDat <- read.table(file = "SimpleDat.csv", sep = ",", header = TRUE)
```
This is element 21 of her history.
```
ex21 = deb$expr[[21]]
```

We want to find the first expression that is like this in the students code.
We do this with
```
z = findSimilarExpr(ex21, s31)
```
This returns
a subset of the student's history 
for the matching expressions.


Now we find another expression
but this time a simple reference to a variable 
which just prints its value.
ytmp is one in deb

```
z = findSimilarExpr(deb$expr[[68]], s31)
```



Finally, we can find literal values.
We look at all the students' history together.
There are 6 numeric expressions, 4 have the value 10000:
```
z = findSimilarExpr(10000, rw)
```




## Customizable

We can use the `compare` parameter to customize how
we compare two expressions.
We can use identical() and this will require that the expressions be identical
in every way.

We default to isEquiv(). This is a new function we introduced and
this, for objects of class call, only compares the arguments
passed in the first. So this would identify the following calls as equivalent:
```
rnorm(10, 1)
rnorm(10, mean = 1)
rnorm(10, mean = 1, 3)
```
But this is not symmetric as it only checks the arguments in the first.
```
isEquiv(quote(rnorm(10, mean = 1, 2)), quote(rnorm(10, 1)))
```

We probably will change isEquiv() so that we check the default values.
But the key point is that we can provide our own functions to define
what we mean by equivalent.





