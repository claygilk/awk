# An Introduction to awk

> AWK (awk /ɔːk/) is a domain-specific language designed for text processing and typically used as a data extraction and reporting tool. Like sed and grep, it is a filter, and is a standard feature of most Unix-like operating systems.
>
> Source: https://en.wikipedia.org/wiki/AWK

`awk` is a very convenient scripting language that has many applications. 
It can be used in bash one-liners to quickly format some data, or you can write an entire `awk` script and place it in its own file.
`awk` is geared towards processing delimited files such as csv or tsv files.
`awk` functions similarly to commands like `sed` or `grep` in that it processes a file (or text from stdin) line-by-line.
Unlike the other two utilities, `awk` will attempt to split up each line using a delimiter. 

The default delimiter in `awk` is a space.
To demonstrate this we can use awk to reformat the output of the `ls` command.
Try running the following in any folder where you have a decent amount of files. 
```shell
ls -l | awk '{print $1, $9}'
```
You should see two columns in the output, the first is the file permissions, and the second is the file name.
How does this command work? When using `awk` you can either pass in a script file using the `-f` flag 
or you can use a one-line script inside single quotes and at least one set of curly brackets.
Within these single quotes anything you write will be interpreted as `awk` statements.

The first `awk` function we will learn is `print`, as you might expect this function prints it's arguments to stdout.
The `$1` argument means *print the value in the first column of each line* (`awk` columns are one-indexed).
Likewise, the `$9` argument means *print the ninth column of each line*.
The comma between the two arguments is optional, and it tells `awk` to separate each column using the same delimiter as the input (which in this case is a space).

If `awk` columns are one-indexed, what happens if we try to print `$0`. Let's try it, run the following command:
```shell
ls -l | awk '{print $0}'
```
You should notice that the output is identical to the `ls -l` command.
This is because `$0` means *all columns*.
So, it doesn't do much here, but it can be useful in some situations.

## Using Different Field Separators
---

The default field separator in `awk` is a space, but we can change this using the `-F` flag.
For example to parse a csv we can use `-F ","`. 
Lets demonstrate how this works using the sample `customers.csv` file.
This file can be found in the source code of this github repository, but for convenience sake I will copy the contents here:

```
customer_id,first_nm,acct_nb,acct_opn_dt,acct_bal
111222333,Mario,123456,2020-01-13Z,100.50
444555666,Luigi,456789,2022-02-28Z,1500.00
777888999,Peach,789123,2021-09-04Z,450.75
```

If we want to extract just the customers name and account balance we could use the following:
```shell
awk -F "," '{print $2,$5}' customers.csv
```
The output should look like this:
```
first_nm acct_bal
Mario 100.00
Luigi 1500.50
Peach 450.75
```
Notice that the output uses a space as the field separator.
This is because `-F` only changes the input field separator.
In order to output a csv we will need to modify our command as follows:
```shell
awk -F "," 'BEGIN{OFS=FS}{print $2,$5}' customers.csv
```
We'll cover the `BEGIN` code block as well as the `END` code block in more detail later.
For now, just know that the code between curly braces and the `BEGIN` keyword executes before `awk` processes any lines of the input.
The line `OFS=FS` means "set the output file separator to be the same as the input file separator.
`OFS` and `FS` are examples of built-in variables that are defined in every `awk` script. 
We'll cover more built-in variables in the next section.

> Quiz 1: Given what you know now, how could you use awk to convert a csv file to a tsv (tab separated) file?

## Built-in Variables
---

### NF The Number of Fields Variable
The variable `NF` stores the number of columns in each row of input. 
For example the following command should print all `5`'s.
```shell
awk -F "," '{print NF}' customers.csv
```
This command isn't very interesting when used on a well-formatted csv, but it can be useful for cleaning up messy data.
Imagine you have a file that is hundreds or thousands of lines long and you want to check if each row is formatted correctly.
We can demonstrate this by using a malformed version of the `customers.csv` file called `customers_err.csv`.
Again this file can be found on the github page, but I will copy it here as well:

```
customer_id,first_nm,acct_nb,acct_opn_dt,acct_bal
111222333,Mario,123456,2020-01-13Z,100.00
444555666,Luigi,456789,2022-02-28Z,1500,50
777888999,Peach,789123,2021-09-04Z,450.75
```

Try running the following command to quickly find the problematic line in `customers_err.csv`.
```shell
awk -F "," '{print NF}' customers_err.csv
```
Your output should look like this:
```shell
5
5
6
5
```

### NR The Number of Records Variable
The command at the end of the last section would be difficult to use if our file was much longer.
We can improve this command however by using the `NR` variable.
The `NR` variable stores the record (aka row) number that awk is currently processing.
Note, that row numbers in `awk` are one-indexed.
The following command prints the line number next to the field (aka column) number:
```shell
awk -F "," '{print NR, NF}' customers_err.csv
```
The expected output of this command:
```
1 5
2 5
3 6
4 5
```

### FS The Input Field Separator
As we briefly saw before `FS` is a built-in variable that stores the delimiter that `awk` will use to parse each line of input.
Just to review, the default value for this variable is a single white-space.
In one-liners it is more common to set this variable at the command line using the `-F` flag.
When writing a stand-alone `awk` script this variable is usually assigned in the `BEGIN` block.

Note, the `FS` variable can be more than one character in length, which is useful when parsing files with multi-character delimiters.
The following snippet is an example of how to use `FS` to parse such a file.
The file used in this example is the same as the `customers.csv` file except the commas have been replaced with double semicolons (i.e `::`):

```
customer_id::first_nm::acct_nb::acct_opn_dt::acct_bal
111222333::Mario::123456::2020-01-13Z::100.50
444555666::Luigi::456789::2022-02-28Z::1500.00
777888999::Peach::789123::2021-09-04Z::450.75
```

This snippet simply prints the first column of the csv.
```shell
awk 'BEGIN{FS="::"} {print $1}' customers_multichar_delim.csv
```

### OFS the Output Field Separator
`OFS` is the built-in variable that `awk` uses to separate fields or columns in the output text. 
There is not much more to say about this variable that hasn't been covered already so instead,
I will use this section to give the answer to `Quiz 1`:

```shell
awk 'BEGIN{FS=",";OFS="\t"}{print $1, $2, $3, $4, $5}' customers.csv
```

In this example we set `FS` to `,` because the file being parsed is a csv,
and we set `OFS` to `\t` or *tab* because we want to output a tsv.
Both of these variables are set in the `BEGIN` block before any lines of input have been processed.
In the main block of code we use `print $1, $2, $3, $4, $5` to print each column separated by the `OFS`.
In this case we cannot use `$0` to print the entire line because `$0` prints the entire line of input as a single field of output. We need to use the commas to tell `awk` to treat all these values as separate fields.

> Note: there is an even shorter way to write this script, but is not intuitive and it would just confuse the matter so I will not include it here. However, if you are curious you can read about it here: https://www.baeldung.com/linux/convert-csv-to-tsv#using-awk

## Code Blocks
---

The basic pattern of the `awk` syntax looks like this:
```
condition { action }
```
So far we have only used the 'action' portion of this pattern.
The 'condition' part can be a boolean expression or the keyword `BEGIN` or the keyword `END`.
The `BEGIN` code block executes before processing the input file.
The `END` code block executes after processing the input file.
Run the following command to see how this works:
```shell
awk -F "," 'BEGIN{print "Starting now!"} {print $0} END{print "All done!"}' customers.csv
```
You should see `Starting now!` printed before the contents of the `customers.csv` file,
and you should see `All done!` printed afterwards. 
Obviously this example is trivial, but like we've seen the `BEGIN` block is useful for initializing variables.
The `End` block is useful when you need to parse the entire file before doing something with the data.
For example, if we want to sum up the total balance across all customer accounts we could use the following `awk` script:
```shell
awk -F "," 'BEGIN{total=0} NR > 1 {total+=$5} END{print "Total=" total}' customers.csv
```
This script uses a lot of the concepts we have learned, so let's review them.
- ```BEGIN{total=0}``` means: before reading the input file create a new variable called `total` and set it to zero.
- ```NR > 1 {total+=$5}``` means: if processing any row after the first one, add the value of the fifth column to the variable `total`.
- ```END{print "Total=" total}``` means: after processing the input file, print out the value of the variable `total`.

## Script Files
---

As pointed out earlier, `awk` scripts can be written in stand-alone files.
These files use the `.awk` extension.
Any of the one-liners used previously could be converted into a script file,
but separate files are usually reserved for more complicated processes.

To pass a script file to `awk` you use the `-f` flag as shown below:
```shell
awk -F "," -f total.awk customers.csv
```
As you can see this makes the command much shorter.
The `total.awk` script used here is a multi-line version of the one-liner used above to calculate the total of all account balances.

No that we know how to use `awk` script files, it is a good time to point out that `awk` files can contain multiple code blocks between the `BEGIN` and `END` blocks. 
To see an example of this you can run the `high_rollers.awk` script against the `customers.csv` file with following command:
```shell
awk -f high_rollers.awk customers.csv
```
The purpose of this trivial script is to process the customer data and tell us who has more than $200 dollars in their account (in other words, who is a high roller).
In order to discuss the contents of this script I will reproduce it here:

```awk
BEGIN {
    FS=","
}

NR > 1 && $5 > 200 {
    print $2, "is a high roller!"
}

NR > 1 && $5 < 200 {
    print $2, "is not a high roller."
}
```

As you can see, after the `BEGIN` block there are two conditional code blocks.
The code to the left of the `{` is the conditional and the code between the code blocks is the action.
As in other programming languages you can combine conditionals in `awk` using boolean operators.
In this example `&&` means AND.
Both blocks share the conditional `NR > 1`, which as we saw before means they will skip the first line of the input file.
The second part of the conditionals compares the value in the fifth column (`$5`) to the integer value of `200`.
If you look at the `customers.csv` file you will see that the fifth column is the `acct_bal` or account balance column.
So in short, the first code block is executed for customers whose account balance is greater than 200, and the second block is executed for customers whose account balance is less than 200.

## User Defined Variables
---

We've already covered some important built-in variables in `awk` but just like other programming languages, you can create your own variables in `awk`.
User defined variables are used in the `total.awk` script, as we saw before.
Variables in `awk` work much like they do in other programming languages.
They are assigned using the `=` operator and they can be modified using any of the following operators: `+=`, `-=`, `*=`, `/=`, `%=`.

The `awk` language does not have a robust type system.
All variables in `awk` are essentially numbers or strings.
You can implicitly covert between strings and numbers in `awk`.
You can define a string variable by placing a value between double quotes.
If a string variable can be converted to a number it will be, but if it cannot be converted to a number it will be converted to a zero.

To demonstrate this implicit conversion lets run the `types.awk` script:

```awk
BEGIN {
    some_string="1"
    some_number=1

    string_plus_string = some_string + "ABC"
    string_plus_number = some_string + some_number
    number_plus_number = some_number + 1

    print "string+string=" string_plus_string
    print "string+number=" string_plus_number
    print "number+number=" number_plus_number
}
```
Notice that this script only contains a `BEGIN` block.
This means any file passed to the `awk` command will be ignored, thus we can leave the file name out of the command and execute this script as shown:

```shell
awk -f types.awk
```
And doing show should produce the following output. 
```
string_plus_string=1
string_plus_number=2
number_plus_number=2
```
Lets break this down. 
In the first operation the variable `some_string` is being combined with the string literal `ABC`.
The `+` operator tell `awk` to try to parse both operands to numbers.
The `some_string` variable can be parsed to the value `1`, but the string `ABC` cannot be interpreted as a number so it defaults to the value `0`. 

In the second operation, the `some_string` variable is again converted to the numeric value `1`.
This time it is being added to the numeric variable `some_number` which also contains the value `1`.
Thus the value of `string_plus_number` is equal to `1+1` or `2`.

In the third operation a numeric variable is being added to a numeric literal so no conversion is taking place. 
Thus, unsurprisingly this operation follows the normal rules of addition.

> Note: the `++` and `--` operators can be used as either prefix or postfix operators in `awk`. Their use is essentially identical to their use in other programming languages like C or Java.

## Arrays in awk
Although it does not support complicated data structures or classes, `awk` does support arrays.
If you are familiar with arrays in other languages `awk` arrays might seem a little strange at first.
In `awk` you don't have to declare an array before you use it.
Nor do you have to worry about using an index that is out of bounds.
The `arrays-1.awk` script demonstrates these peculiar behavior of arrays in `awk`.

```awk
BEGIN {
    some_array[2]="two"
    print "some_array[0]=" some_array[0]
    print "some_array[1]=" some_array[1]
    print "some_array[2]=" some_array[2]
    print "some_array[3]=" some_array[3]
}
```

On the first line of this script the `some_array` variables is being declared, initialized and used all at once.
Unlike column and line numbers, `awk` uses zero-indexing for its arrays.
So the first line is setting the value of the third element of the array to the string `abc`.
If you run the this script(```awk -f arrays-1.awk```) you should see the following output:
```
some_array[0]=
some_array[1]=
some_array[2]=two
some_array[3]=
```

Another property of arrays in `awk` is that they are associative, meaning they associate one value (or index) with another value (element).
This index value does not have to be a positive integer, can be also be a string.
Unlike most programming languages, arrays in `awk` do not represent a contiguous region of memory that is fixed in size.
These features make arrays in `awk` more similar to maps or dictionaries in other languages.
In the `arrays-2.awk` script we can see how arrays can be used like maps.

```
BEGIN {
    capitols["Ohio"] = "Columbus"
    capitols["Alaska"] = "Juno"
    capitols["Texas"] = "Austin"

    print "The capitol of Ohio is " capitols["Ohio"] 
    print "The capitol of Alaska is " capitols["Alaska"] 
    print "The capitol of Texas is " capitols["Texas"] 
}
```

In the first three lines string values are being assigned to an array with string indexes, 
and in the nex three lines the values are being read from the array.
Running this script (```awk-f arrays-2.awk```) produces the following output:

```
The capitol of Ohio is Columbus
The capitol of Alaska is Juno
The capitol of Texas is Austin
```

One of the most common things to do with an array is to loop over each element and execute some block of code.
We will see how to do that in the following section.


## Loops in awk
---

Like other programming languages `awk` allows you to use `for` loops and `while` loops.
`awk` supports C-style `for` loops, and it's `while` loops do not are very similar to `while` loops in common programming languages so won't go into detail on how to use them here. 

While you can iterate through all the elements of an array with a C-style `for` loop, it is often easier to use the following syntax. This is similar to a `for each` loop in other languages.

```awk
for(index in some_array){
    code block
}
```
Let's rewrite the `arrays-2.awk` script using this syntax.
The `arrays-3.awk` file shows how to do so.
```
BEGIN {
    capitols["Ohio"] = "Columbus"
    capitols["Alaska"] = "Juno"
    capitols["Texas"] = "Austin"

    for(state in capitols){
        print "The capitol of " state " is " capitols[state] 
    }
}
```

The start of this script is identical to the start of `arrays-2.awk`.
It sets up an array with three elements.
The second part of this script uses a `for` loop to iterate over each index in the array and assign it to a variable named `state`.
In the body of the statement this variable can be used directly or it can be use as an index to access the different elements of the array.

## Functions in awk
The syntax to declare a function in awk is similar to the syntax in languages like bash and JavaScript. 
You can use the `function` or `func` followed by the method name and parameters as shown below:

```awl
function myFunction(){}

func myOtherFunction(){}
```

Functions in awk do not require a return type.
Nor do function arguments require a type.
And, as you might have guessed to return a value from function you use the `return` keyword followed by the value.

Lets demonstrate all of this with a trivial function that adds two numbers.

```awk
BEGIN {
    print add(1,2)
}
function add(x, y){
    return x + y
}
```

When we execute this script (using `awk -f functions-1.awk`), it should print the number `3`.
This example also shows that unlike bash or C, functions in `awk` do not need to be declared before they are used.

### Built-in Functions
`awk` includes many helpful built in functions.
It would be beyond the scope of this quick introduction to document all of them in detail.
But I will include a list of some of the most useful ones and a brief description of what they do:

- `rand()` - generates a random number between 0 and 1
- `length(string)` - returns the length of a string variable
- `tolower(string)` - converts a string to lower case
- `toupper(string)` - converts a string to upper case
- `gsub(regex, replacement, [,target])` - functions like `sed` to find and replace text
- `sprintf(pattern, values...)` - format a string variable. Nearly identical to `sprintf` in C

> Note: For a more comprehensive list visit https://www.gnu.org/software/gawk/manual/gawk.html#Built_002din

## Conditionals in awk
We've already seen that an `awk` script is composed of zero or more conditional code blocks, but we can also use conditionals within a code block.
Lets briefly look at how to use the `if` and `while` keywords.
These keywords work very similar to how they work in other C-style languages, so I'll just put a brief example here so you can get a feel for the syntax.

```awk
BEGIN {
    i = 1
    while (i <= 15){
        if(i % 3 == 0 && i % 5 == 0) {
            print "fizzbuzz"
        }
        else if ( i % 3 == 0) {
            print "fizz"
        } 
        else if ( i % 5 == 0) {
            print "buzz"
        } else {
            print i
        }
        i++
    }
}
```

This example shows how to solve the (in)famous FizzBuzz problem in `awk`.
You can run this script with `awk -f conditionals-1.awk` to verify it's output.

## Putting it all together
Now we know enough to be dangerous with `awk`.
In this section we will work with a slightly larger csv file (`homes.csv`) which can be downloaded from this site: https://people.sc.fsu.edu/~jburkardt/data/csv/csv.html.
This file includes some made-up home sale data.
This file has 50 rows so I will only include the first few rows here, but the entire file can be found in the source code of this repo.

```
Sell,List,Living,Rooms,Beds,Baths,Age,Acres,Taxes
142,160,28,10,5,3,60,0.28,3167
175,180,18,8,4,1,12,0.43,4033
129,132,13,6,3,1,41,0.33,1471
138,140,17,7,3,1,22,0.46,3204
```

### Example 1 - Reformatting
Let's write some `awk` scripts to process this file.
The first script we will look at is `homes-1.awk` which will clean-up and reformat the data.
The imaginary purpose of this script is to reformat the data so that it is easier to compare the price of a house and the rate of tax applied.

Here is the entire script:

```awk
BEGIN {
    FS=","
    OFS=FS
    print "SellPrice", "TaxPercent", "TaxAmount"
}

NR > 1 {
    sellPrice = $1*1000
    sellPriceString = sprintf("$%d", sellPrice)
    
    taxAmount = $9
    taxAmountString = sprintf("$%d", taxAmount)

    taxPercent = (taxAmount / sellPrice) * 100
    taxPercentString = sprintf("%.2f%%", taxPercent)
    
    print sellPriceString, taxPercentString, taxAmountString
}
```

Let's step through this script together.
First, in the `BEGIN` code block we set the `FS` and `OFS` variables to be a `,` since we are processing a csv and we would like the output of our script to also be a csv.
Next, we print the new column names for our output file.

In the `NR > 1` block we process all the data rows in the file.
We convert the "Sell" column to dollars (by multiplying by 1000) then add a dollar sign on the front to make the unit clear.
We define two variables `sellPrice` and `sellPriceString` for use later in the script.
The former is simply an alias for the first column, which is useful so that we don't have to remember column numbers as we are coding.
The latter is a formatted string created with the `sprintf` function.

After creating these variables we will do much the same thing with the "Taxes" column.
We alias the column with the `taxAmount` variable and we create a formated string called `taxAmountString` which includes a dollar sign. 

Lastly, we calculate the tax rate on the sale by using our previously defined variables and using `sprintf` to format the output.

Once all the variables have been set, we print them out in the same order as the new column names defined above.
After running this script (`awk -f homes-1.awk homes.csv`) you should see the following output:

```
SellPrice,TaxPercent,TaxAmount
$142000,2.23%,$3167
$175000,2.30%,$4033
$129000,1.14%,$1471
...
$247000,1.87%,$4626
$111000,2.89%,$3205
$133000,2.30%,$3059
```

### Example 2 - Aggregation
The previous example demonstrates what I think `awk` does best: manipulating tabular data into a similar but different format.
However you might find yourself needing to do more with awk.

In the next example script (`homes-2.awk`) we will see how we can use `awk` to calculate aggregated values from our data.
This script will process the `homes.csv` file and generate a new file that shows the average house price when grouping by the number of rooms.

Here is the script:

```awk
BEGIN {
    FS=","
    OFS=FS
    print "NumberOfRooms", "AveragePrice"
}
NR > 1 {
    rooms=$4
    sellPrice=$1
    housesBySize[rooms] = housesBySize[rooms] + 1
    sellPriceSum[rooms] = sellPriceSum[rooms] + sellPrice
}
END {
    for(numOfRooms in housesBySize){
        avg = (sellPriceSum[numOfRooms] / housesBySize[numOfRooms]) * 1000
        avgFormatted = sprintf("$%.2f", avg)
        print numOfRooms, avgFormatted
    }
}
```

In this script we're using the some of the same techniques we used in the last script: setting the file separators in the `BEGIN` block, printing new column names and creating aliases for column numbers.
What's new is the use of arrays.

In the `NR > 1` block, we create and populate two arrays: `housesBySize` and `sellPriceSum`.
The former stores the count of the number of houses with that number of rooms.
For example if there were 3 houses with 6 rooms then `housesBySize[6] == 3` would be true.
In the `sellPriceSum` array we are keeping a running total of the sale price of each size of house.
This syntax might look a little weird, but just as a reminder you do not need to declare an array in `awk` before you start using it.

Then, in the `END` block we perform some post processing on our two arrays.
We use a `for` loop to iterate through each house size.
In each iteration we calculate the average sale price by dividing the total sale price for all houses of a given size by the number of houses of that size.
We then use some multiplication and `sprintf` to format the `avg` variable in a more human-friendly format.
Lastly, we print out the two values we are interested in in the same order we printed our column names.

Running this script (`awk -f homes-2.awk homes.csv`) should produce the following output:

```
NumberOfRooms,AveragePrice
5,$89000.00
6,$135333.33
7,$139636.36
8,$162523.81
9,$180875.00
10,$212000.00
11,$567000.00
12,$212000.00
```

## Where can I learn more?
I hope you enjoyed this brief introduction to `awk` and I hope you get the chance to use what you've learned!
If you are curious and would like to learn more, I would highly recommend the following two sites.
The first site is more succinct and good for as a quick reference. The second is more thorough and is good if you need to consult detailed documentation.

- https://www.grymoire.com/Unix/Awk.html
- https://www.gnu.org/software/gawk/manual/gawk.html