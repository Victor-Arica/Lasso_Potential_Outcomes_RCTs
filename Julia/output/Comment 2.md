## 1.2 Cross-Validation in Machine Learning

**Cross-validation** is a resampling technique that splits the data into subsets for training and validation in order to **evaluate the performance of the model**.

It is useful because:  
- It provides an **unbiased estimate** of the model’s performance on unseen data.  
- It allows for **hyperparameter tuning** (e.g., optimal selection of λ in LASSO).  
- It **reduces overfitting** by testing on multiple validation sets.  
- It helps in **model selection and comparison**.  

---

### Example: Step-by-step Cross-Validation

1. **Split the data**  
   Randomly divide the data into **K equal groups**.  

2. **Iterate over each group k (k = 1, 2, ..., K):**  
   - Use group *k* as the **validation set**.  
   - Use the remaining **K-1 groups** as the **training set**.  
   - Train the model and compute the **validation error**.  

3. **Average errors**  
   Average the **K validation errors** and determine the optimal form of the model for correct application.

---

The following image helps to better understand the procedure:

![Grid Search Cross Validation](https://scikit-learn.org/stable/_images/grid_search_cross_validation.png)


