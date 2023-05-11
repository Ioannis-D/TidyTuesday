This week, the file comes from the [National Database of Childcare Prices](https://www.dol.gov/agencies/wb/topics/featured-childcare).

I have made two plots, one showing the change of childcare costs across the States and the second shows the cost for each county. 

Apart from that, I make a quick regression to see if unmeployment and income affect childcare costs with the results not being statistically significant. 


|                | Estimate| Std..Error| t.value| Pr...t..|    SE|
|:---------------|--------:|----------:|-------:|--------:|-----:|
|(Intercept)     |   57.272|     45.158|   1.268|    0.273| 1.778|
|avg_unr_16      |  194.677|   1225.764|   0.159|    0.882| 1.778|
|avg_funr_16     |   59.094|    480.024|   0.123|    0.908| 1.778|
|avg_munr_16     | -316.520|    762.174|  -0.415|    0.699| 1.778|
|avg_unr_20to64  | 1445.964|    918.221|   1.575|    0.190| 1.778|
|avg_funr_20to64 | -786.452|    459.802|  -1.710|    0.162| 1.778|
|avg_munr_20to64 | -579.662|    495.170|  -1.171|    0.307| 1.778|

