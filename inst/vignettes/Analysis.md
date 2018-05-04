

We start with Deb's prepared code from the class.
```
deb = readRDS("DebsCode.rds")
```


We load the information from all of the students history files into R
already processed by RHistoryAnalysis. This is `rw`.
This is a single data.frame with columns ID, date, src, expr, isInlineComment, isComment, lineNum.
We'll pull out one student - ID == 31 and the first day of the workshop
```
s31 = rw[ rw$ID==31 & rw$date == 19,]
```


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


