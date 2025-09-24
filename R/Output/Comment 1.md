# Very Large Lambda

In this case, the penalty on the size of the coefficients is extreme.  
This causes all coefficients to shrink exactly to zero.  
The model predicts the mean of the outcome variable for all observations, which results in **high bias** and a **high training error** (*underfitting*).  

The test error is also high because the model fails to capture any pattern in the data due to the **excessive simplification**.

---

# Very Small Lambda

Here, the opposite occurs: the penalty becomes negligible.  
The **Lasso** estimate approaches the **ordinary least squares (OLS)** estimate.  

The model may include many coefficients, including those of irrelevant variables, leading to **high variance** (*overfitting*).  
The training error will be very low, but the test error is likely to be high because the model fits the **noise in the training data**.  

Put simply, it *“memorizes”* the data, and therefore cannot generalize its predictions.




