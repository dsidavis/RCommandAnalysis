# Getting Started

Install the package or just source R/read.R.


We read a history file, including the comments.
```r
f = system.file("sampleCode", "eg1", package = "RCommandAnalysis")
exprs = readCode(f)
```
`exprs$expr` is now a list with each of the elements
being either a call, =, or some language object, 
or a Comment object.
```r
sapply(exprs$expr, class)
```
```
 [1] "call"    "call"    "Comment" "call"    "="       "call"   
 [7] "call"    "Comment" "call"    "call"   
```

Now, we convert this to a data frame with a row for each function
called or a comment:
```r
df = longDF(exprs$expr)
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
info parameter in longDF(), e.g., which variables are
created, update, used in a computation.


How many comments are there?
```
table(sapply(exprs$expr, is, "Comment"))
```
We can also compute this from the data frame with
```
table(!is.na(df$comment))
```


# The Data Frame from readCode()

Originally, readCode() just returned the expr column as a list.
However, now readCode() returns a data frame which contains more information
about the comments.
```r
exprs = readCode(f)
dim(exprs)
```
```
[1] 10  5
```
```r
names(exprs)
```
```
[1] "src"             "expr"            "isInlineComment"
[4] "isComment"       "lineNum"        
```
The src and expr come from parse_all(), although 
+ the text is trimmed (whitespace removed from the start and end),
+ empty rows are discarded from the data frame,
+ empty comments are removed from the text.

The column lineNum gives the line number for each entry.
This is no longer necessarily the line number in the file
since empty rows are removed. For most history files, there are
no empty lines (or only at the end), so the line numbers may
correspond to those in the file.

isInlineComment indicates whether the expr
has an inline comment, i.e., after some code.
isComment indicates whether the text is simply a comment,
i.e., without any code.

To get the comments, we can use getComments(), e.g.,
```r
d = readCode("inlineComments")
getComments(d)
```

# Two Tables

The code I just pushed has the information for each of your 2 tables aggregated 
into a single table.

Let's start with
```r
w = readCode("inlineComments")
```

Now we extract the two tables - one for code and the other for the comments
```r
w2 = longDF2(w)
```
This is a list with 2 elements - code and comments.
Both are data frames.
```r
sapply(w2, class)
sapply(w2, dim)
```

```
        code     comments 
"data.frame" "data.frame" 
     code comments
[1,]    5        3
[2,]    3        5
```

The names for each data frame are
```r
sapply(w2, names)
$code
[1] "lineNum"   "comment"   "functions"

$comments
[1] "src"             "expr"            "isInlineComment"
[4] "isComment"       "lineNum"        
```

For code, we are only interested in lineNum and functions.
(The comment column is left over from the original longDF()
function where we kept the comments and the code together and still can.)
This now only contains the code elements.

The comments element contains the comments
and is the subset of rows that are comments of any form (regular or inline).


## Reading a CSV file of Code.
```r
f = system.file("sampleCode", "p1raw.csv", package = "RCommandAnalysis")
exprs = readCode(f)
df = longDF(exprs)
dim(df)
```
