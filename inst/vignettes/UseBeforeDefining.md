In student 31, we notice

```
head(simpleDat)
simpleDat <- read.table(file="SimpleDat.csv", sep= ",", header=TRUE)
```
(in positions 25 and 26)
S/he tries to look at a variable before it is defined.
Similarly, we see
```
head(P5)
names(P5)
P5 <- read.csv ("~/Documents/My Documents/Grad docs-Davis/Class/2015Fall/STA100/chap15q30.csv", sep=",", header=TRUE)
names(P5)
```
This is the same thing.

This is very common and may not be of interest.
However, it may also suggest a lack of understanding of the sequential nature.

We can find these premature uses of variables using CodeDepends.

We start by reading the data:
```
deb = readRDS("DebsCode.rds")
rw = readRDS("baseRaw.rds")
s31 = rw[ rw$ID==31 & rw$date == 19,]
```


```
library(CodeDepends)
i = as(unclass(s31$expr), "Script")
info = as(i, "ScriptInfo")
```

We know which variable we are looking for (simpleDat)
and the list expressions in which we are looking for the definition.
```
getVariableDepends("simpleDat", i[1:25], info = info[1:25])
```
The answer we get is NULL. So there is no definition of the variable
in these 25 previous expressions.
This is why s31 defined it in the next command!

getVariableDepends is just a little bit more than
```
"simpleDat" %in% sapply(info[1:25, slot, "outputs")
```

